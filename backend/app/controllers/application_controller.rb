class ApplicationController < ActionController::API
  before_action :authenticate!
  rescue_from AppException, with: :handle_app_exception

  def authenticate!
    header = request.headers["Authorization"]
    token = header&.split&.last
    payload = token && JwtService.decode(token)

    return render(json: {error: "Unauthorized"}, status: :unauthorized) unless payload

    user = User.find_by(id: payload["sub"])
    return render(json: {error: "Unauthorized"}, status: :unauthorized) unless user

    Current.user = user
  end

  private

  def handle_app_exception(e)
    render json: {
      error: e.message,
      details: e.details
    }, status: e.status_code
  end
end
