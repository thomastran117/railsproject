class BaseCacheService
  def initialize(redis: REDIS, namespace: nil)
    @redis = redis
    @namespace = namespace
  end

  private

  attr_reader :redis

  def ns(key)
    return key.to_s if @namespace.nil? || @namespace.to_s.strip.empty?
    "#{@namespace}:#{key}"
  end

  def execute(fallback = nil)
    yield
  rescue Redis::BaseError, Timeout::Error, Errno::ECONNRESET, Errno::ECONNREFUSED
    fallback
  end
end
