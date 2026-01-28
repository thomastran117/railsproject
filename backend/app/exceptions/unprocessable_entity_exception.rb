class UnprocessableEntityException < AppException
  DEFAULT_MESSAGE = "Unprocessable Entity"
  STATUS_CODE = 422

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end