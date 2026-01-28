class ConflictException < AppException
  DEFAULT_MESSAGE = "Conflict"
  STATUS_CODE = 409

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end