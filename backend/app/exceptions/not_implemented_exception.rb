class NotImplementedException < AppException
  DEFAULT_MESSAGE = "Not implemented"
  STATUS_CODE = 501

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end