class ForbiddenException < AppException
  DEFAULT_MESSAGE = "Forbidden"
  STATUS_CODE = 403

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end