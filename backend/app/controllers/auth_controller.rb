class AuthController < ApplicationController
  skip_before_action :authenticate!, only: [:signup, :login]
  
  def signup_params
    params.permit(:email, :password, :password_confirmation, :role)
  end

  def login_params
    params.permit(:email, :password)
  end

  def signup
    user = User.new(signup_params)

    if user.save
      token = JwtService.encode({sub: user.id})
      render json: {user: safe_user(user), access_token: token}, status: :created
    else
      render json: {error: "Validation failed", details: user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: login_params[:email])

    unless user&.authenticate(login_params[:password])
      return render json: {error: "Invalid credentials"}, status: :unauthorized
    end

    token = JwtService.encode({sub: user.id})
    render json: {user: safe_user(user), access_token: token}
  end

  def me
    render json: {user: safe_user(Current.user)}
  end

  private

  def safe_user(user)
    {
      id: user.id,
      email: user.email,
      role: user.role,
      created_at: user.created_at
    }
  end
end
