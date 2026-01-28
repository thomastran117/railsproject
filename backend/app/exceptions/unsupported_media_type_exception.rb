class UnsupportedMediaTypeException < AppException
  DEFAULT_MESSAGE = "Unsupported media type"
  STATUS_CODE = 415

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end