class PayloadTooLargeException < AppException
  DEFAULT_MESSAGE = "Payload too large"
  STATUS_CODE = 413

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end