module EnvManager
  class MissingEnvError < StandardError; end

  module_function

  def get_optional(key)
    val = ENV[key.to_s]
    return nil if val.nil? || val.strip.empty?

    val
  end

  def get_or_default(key, fallback)
    get_optional(key) || fallback
  end

  def fetch!(key)
    get_optional(key) || raise(MissingEnvError, "Missing required ENV: #{key}")
  end

  def db_url
    @db_url ||= get_or_default(
      "DATABASE_URL",
      "postgres://postgres:password123@localhost:5432/hrapp"
    )
  end

  def redis_url
    @redis_url ||= get_or_default(
      "REDIS_URL",
      "redis://localhost:6379/0"
    )
  end

  def app_environment
    @app_environment ||= get_or_default("APP_ENV", Rails.env).downcase
  end

  def log_level
    @log_level ||= get_or_default("LOG_LEVEL", "info").downcase
  end

  def validate!
    if %w[development test].include?(app_environment)
      Rails.logger.warn("Skipping environment validation (dev/test mode).")
      return
    end

    required = {
      "DB_URL" => db_url,
      "REDIS_URL" => redis_url
    }

    missing = required.select { |_k, v| v.nil? || v.strip.empty? }.keys
    raise MissingEnvError, "Missing required environment variables: #{missing.join(', ')}" if missing.any?

    Rails.logger.info("Environment variables validated successfully.")
  end

  def reset!
    @db_url = @redis_url = @app_environment = @log_level = nil
  end
end
