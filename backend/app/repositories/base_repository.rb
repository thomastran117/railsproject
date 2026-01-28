require "timeout"

class BaseRepository
  CIRCUIT_CLOSED = :closed
  CIRCUIT_OPEN   = :open

  MAX_RETRIES            = 3
  BASE_DELAY_MS          = 100
  TIMEOUT_SECONDS        = 3
  CIRCUIT_FAIL_THRESHOLD = 2
  CIRCUIT_OPEN_SECONDS   = 10

  def initialize
    @mutex = Mutex.new
    @circuit_state = CIRCUIT_CLOSED
    @opened_until = nil
    @transient_failures = 0
  end

  def database_healthy?
    circuit_state == CIRCUIT_CLOSED
  end

  protected

  def execute(allow_retry: true, &block)
    raise ArgumentError, "execute requires a block" unless block

    raise circuit_open_error(operation_name) if circuit_open?

    attempt = 0

    begin
      attempt += 1

      result = run_with_timeout(&block)
      on_success
      result
    rescue StandardError => e
      raise unless transient?(e)

      on_transient_failure

      raise circuit_open_error(operation_name, cause: e) if circuit_open?
      raise if !allow_retry || attempt > MAX_RETRIES

      sleep(backoff_with_jitter_seconds(attempt))
      retry
    end
  end

  def execute_void(allow_retry: true, &block)
    execute(allow_retry: allow_retry, &block)
    nil
  end

  def operation_name
    loc = caller_locations(3, 1)&.first
    method = loc&.label || "unknown"
    "#{self.class.name}.#{method}"
  end

  def transient?(ex)
    return true if ex.is_a?(Timeout::Error)

    return true if defined?(ActiveRecord::Deadlocked) &&
                   ex.is_a?(ActiveRecord::Deadlocked)

    return true if defined?(ActiveRecord::LockWaitTimeout) &&
                   ex.is_a?(ActiveRecord::LockWaitTimeout)

    return true if defined?(ActiveRecord::ConnectionTimeoutError) &&
                   ex.is_a?(ActiveRecord::ConnectionTimeoutError)

    return true if defined?(PG::UnableToSend) &&
                   ex.is_a?(PG::UnableToSend)

    return true if defined?(Mysql2::Error) &&
                   ex.is_a?(Mysql2::Error) &&
                   mysql_transient?(ex)

    false
  end

  def mysql_transient?(ex)
    msg = ex.message.to_s.downcase
    msg.include?("deadlock") ||
      msg.include?("lock wait timeout") ||
      msg.include?("server has gone away") ||
      msg.include?("lost connection")
  end

  def run_with_timeout
    Timeout.timeout(TIMEOUT_SECONDS) { yield }
  end

  def backoff_with_jitter_seconds(attempt)
    base = BASE_DELAY_MS * (2**attempt)
    jitter = 0.5 + thread_random.rand
    (base * jitter) / 1000.0
  end

  def thread_random
    Thread.current[:_repo_jitter_rng] ||= Random.new
  end

  def circuit_state
    @mutex.synchronize do
      if @circuit_state == CIRCUIT_OPEN &&
         @opened_until &&
         Time.now >= @opened_until
        close_circuit
      end

      @circuit_state
    end
  end

  def circuit_open?
    circuit_state == CIRCUIT_OPEN
  end

  def on_success
    close_circuit
  end

  def on_transient_failure
    @mutex.synchronize do
      @transient_failures += 1

      if @transient_failures >= CIRCUIT_FAIL_THRESHOLD
        @circuit_state = CIRCUIT_OPEN
        @opened_until = Time.now + CIRCUIT_OPEN_SECONDS
      end
    end
  end

  def close_circuit
    @mutex.synchronize do
      @circuit_state = CIRCUIT_CLOSED
      @opened_until = nil
      @transient_failures = 0
    end
  end

  def circuit_open_error(op, cause: nil)
    err = RuntimeError.new("Circuit open: #{op}")
    err.set_backtrace(cause.backtrace) if cause
    err
  end
end
