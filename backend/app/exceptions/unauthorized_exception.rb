class UnauthorizedException < AppException
  DEFAULT_MESSAGE = "Unauthorized"
  STATUS_CODE = 401

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end