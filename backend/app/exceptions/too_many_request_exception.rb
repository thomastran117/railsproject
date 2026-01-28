class TooManyRequestException < AppException
  DEFAULT_MESSAGE = "Too many requests"
  STATUS_CODE = 429

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end