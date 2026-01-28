class MethodNotAllowedException < AppException
  DEFAULT_MESSAGE = "Method not allowed"
  STATUS_CODE = 405

  def initialize(message = DEFAULT_MESSAGE, details: nil)
    super(message, status_code: STATUS_CODE, details: details)
  end
end