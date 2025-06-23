RrxApi::Engine.routes.draw do
  if Rails.root.join('swagger').exist?
    require 'rswag/api/engine'
    require 'rswag/ui/engine'

    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  healthcheck_path = Rails.application.config.healthcheck_route
  healthcheck_path = "/#{healthcheck_path}" unless healthcheck_path.start_with?('/')
  get healthcheck_path => 'rrx_api/health#show', as: :rrx_health_check
end
