Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check
  scope :auth do
    post :signup, to: "auth#signup"
    post :login, to: "auth#login"
    get :me, to: "auth#me"
  end
end
