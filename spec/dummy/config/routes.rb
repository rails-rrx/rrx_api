Rails.application.routes.draw do
  mount RrxApi::Engine => '/'

  controller :test do
    get :test
  end
end
