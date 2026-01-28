class ApplicationController < ActionController::API
  before_action :authenticate!

  def authenticate!
    header = request.headers["Authorization"]
    token = header&.split&.last
    payload = token && JwtService.decode(token)

    return render(json: {error: "Unauthorized"}, status: :unauthorized) unless payload

    user = User.find_by(id: payload["sub"])
    return render(json: {error: "Unauthorized"}, status: :unauthorized) unless user

    Current.user = user
  end
end
