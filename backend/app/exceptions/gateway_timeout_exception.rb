class GatewayTimeoutException < AppException
  DEFAULT_MESSAGE = "Gateway timeout"
  STATUS_CODE = 504

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end