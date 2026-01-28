class BadRequestException < AppException
  DEFAULT_MESSAGE = "Bad request"
  STATUS_CODE = 400

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end