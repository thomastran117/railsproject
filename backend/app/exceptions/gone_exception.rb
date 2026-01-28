class GoneException < AppException
  DEFAULT_MESSAGE = "Gone"
  STATUS_CODE = 410

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end