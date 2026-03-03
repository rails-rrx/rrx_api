# frozen_string_literal: true

module RrxApi
  class Controller < ActionController::API
    include AbstractController::Helpers
    include RrxApi::Authenticatable

    abstract!

    # @return [RrxLogging::Logger]
    def logger
      RrxLogging.current || Rails.logger
    end
  end
end
