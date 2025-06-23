# frozen_string_literal: true

module RrxApi
  # Replaces the default Rails health check controller
  class HealthController < RrxApi::Controller
    rescue_from(Exception) { |error| render_down(error) }

    def show
      check
      render_up
    end

    protected

    def check
      healthcheck = Rails.application.config.healthcheck
      instance_exec(&healthcheck) if healthcheck.respond_to?(:call)
    end

    def render_up
      render json: { status: 'up' }, status: :ok
    end

    # @param [Exception] error
    def render_down(error)
      render json: {
        status: 'down',
        message: error.message,
        full_message: error.full_message(order: :top)
      }, status: :internal_server_error
    end
  end
end
