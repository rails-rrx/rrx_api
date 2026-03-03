Rails.application.routes.draw do
  mount RrxApi::Engine => '/'

  controller :test do
    get :test
  end

  controller :auth_test do
    get :open
    get :protected_action
    get :token_expired_action
  end
end
