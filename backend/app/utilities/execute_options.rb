
class ExecuteOptions
  attr_reader :operation_name, :allow_retry

  def initialize(operation_name: "RepositoryOperation", allow_retry: true)
    @operation_name = operation_name
    @allow_retry = allow_retry
  end

  def self.default(name = nil)
    new(operation_name: name || "RepositoryOperation", allow_retry: true)
  end

  def self.no_retry(name = nil)
    new(operation_name: name || "RepositoryOperation", allow_retry: false)
  end
end