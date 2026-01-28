class AppException < StandardError
  attr_reader :status_code, :details

  def initialize(message = nil, status_code: 500, details: nil)
    raise NotImplementedError, "AppException is abstract" if instance_of?(AppException)

    super(message)
    @status_code = status_code
    @details = details
  end
end
