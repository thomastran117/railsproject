class BadGatewayException < AppException
  DEFAULT_MESSAGE = "Bad gateway"
  STATUS_CODE = 502

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end