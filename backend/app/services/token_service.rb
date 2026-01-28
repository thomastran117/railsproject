class TokenService
  ALGO = "HS256"

  def self.secret
    ENV.fetch("JWT_SECRET")
  end

  def self.encode(payload, exp: 15.minutes.from_now)
    payload = payload.merge(exp: exp.to_i)
    JWT.encode(payload, secret, ALGO)
  end

  def self.decode(token)
    decoded, = JWT.decode(token, secret, true, {algorithm: ALGO})
    decoded
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
