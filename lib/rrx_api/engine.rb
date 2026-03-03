require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_text/engine'
require 'action_view/railtie'
require 'jbuilder'
require 'rack/cors'
require 'actionpack/action_caching'
require_relative 'auth/base'
require_relative 'auth/firebase'

module RrxApi
  class Engine < ::Rails::Engine
    CORS_LOCALHOST_PATTERN = /\Ahttp:\/\/localhost(?::\d{4})?\z/.freeze

    config.cors_origins = []

    # Checks whether +source+ matches any of the configured CORS origins.
    # Each entry in +cors_origins+ may be:
    # - a String for exact match (e.g. "https://app.example.com")
    # - a String with a leading wildcard (e.g. "*.example.com" matches "https://foo.example.com")
    # - a Regexp (e.g. /\.example\.com\z/)
    def self.cors_origin_allowed?(source, origins)
      origins.any? do |origin|
        case origin
        when Regexp then origin.match?(source)
        when String
          if origin.start_with?('*.')
            # Wildcard subdomain: *.example.com matches any scheme+subdomain of example.com
            suffix = origin[1..]  # => ".example.com"
            source.end_with?(suffix)
          else
            source == origin
          end
        end
      end
    end
    config.healthcheck = nil
    config.healthcheck_route = 'healthcheck'

    initializer 'rrx.active_support', before: 'active_support.set_configs' do |app|
      app.config.active_support.to_time_preserves_timezone = :zone
    end

    initializer 'rrx.application', before: :initialize do |app|
      app.config.time_zone                                 = :utc
      app.config.active_support.to_time_preserves_timezone = :zone
      app.config.active_record.schema_format               = :sql # Use SQL schema format for UUID support

      app.config.generators.orm :active_record, primary_key_type: :uuid
      app.config.session_store :cookie_store, key: '_rrx_session' # Make configurable in the future?
      app.config.middleware.use ActionDispatch::Cookies # Required for all session management
      app.config.middleware.use ActionDispatch::Session::CookieStore, app.config.session_options
    end

    initializer 'rrx.cors', before: :load_config_initializers do |app|
      require 'rack/cors'

      Rails.application.config.middleware.insert_before 0, Rack::Cors do
        allow do
          origins do |source, _env|
            if Rails.env.development?
              CORS_LOCALHOST_PATTERN.match? source
            else
              Engine.cors_origin_allowed?(source, app.config.cors_origins)
            end
          end

          resource '*',
                   headers:     :any,
                   credentials: true,
                   methods:     [:get, :post, :put, :patch, :delete, :options, :head]
        end
      end

    end

    initializer 'rrx.api_docs_config', before: :load_config_initializers do |_app|
      Rails.configuration.api_docs = { 'API' => 'swagger.yaml' }
    end

    initializer 'rrx.api_docs', after: :load_config_initializers do |app|
      # Setup Swagger endpoints if docs exist
      if swagger_root?
        require 'rswag/api'
        require 'rswag/ui'

        Rswag::Api.configure do |c|
          c.swagger_root = Rails.root.join('swagger')
        end

        Rswag::Ui.configure do |c|
          app.config.api_docs.each_pair do |name, file|
            c.swagger_endpoint "/api-docs/#{file}", name
          end
        end
      end
    end

    private

    def swagger_root
      @swagger_root ||= Rails.root.join('swagger')
    end

    def swagger_root?
      swagger_root.exist?
    end
  end
end
