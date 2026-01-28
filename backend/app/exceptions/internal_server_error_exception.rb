class InternalServerErrorException < AppException
  DEFAULT_MESSAGE = "Internal server error"
  STATUS_CODE = 500

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end