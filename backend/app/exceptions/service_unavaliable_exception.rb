class ServiceUnavaliableException < AppException
  DEFAULT_MESSAGE = "Service unavaliable"
  STATUS_CODE = 503

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end