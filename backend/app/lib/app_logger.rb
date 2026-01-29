require "fileutils"
require "time"

class AppLogger
  LOG_DIR  = Rails.root.join("logs").freeze
  LOG_FILE = LOG_DIR.join("error.log").freeze

  LEVEL_COLORS = {
    info:  "\e[34m[INFO]\e[0m",
    warn:  "\e[33m[WARN]\e[0m",
    error: "\e[31m[ERROR]\e[0m",
    debug: "\e[36m[DEBUG]\e[0m",
    log:   "\e[37m[LOG]\e[0m"
  }.freeze

  class << self
    def info(msg)  = log(:info, msg)
    def warn(msg)  = log(:warn, msg)
    def error(msg) = log(:error, msg)
    def debug(msg) = log(:debug, msg)
    def log_msg(msg) = log(:log, msg)

    private

    def timestamp
      Time.now.utc.iso8601
    end

    def ensure_log_dir!
      FileUtils.mkdir_p(LOG_DIR)
    end

    def log_to_file(level, message)
      ensure_log_dir!
      entry = "[#{timestamp}] [#{level.to_s.upcase}] #{message}\n"
      File.open(LOG_FILE, "a") { |f| f.write(entry) }
    rescue StandardError
      # intentionally ignored
    end

    def log(level, message)
      time = "\e[90m[#{timestamp}]\e[0m"
      level_tag = LEVEL_COLORS[level] || "[#{level.to_s.upcase}]"

      puts "#{time} #{level_tag} #{message}"

      log_to_file(level, message) if %i[warn error].include?(level)
    end
  end
end
