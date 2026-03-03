# frozen_string_literal: true

require_relative 'base'

module RrxApi
  module Auth
    # Firebase authentication provider.
    #
    # Requires the +firebase-admin-sdk+ gem. It is intentionally not listed as a
    # dependency of rrx_api — add it to your application's Gemfile when you want
    # Firebase auth:
    #
    #   gem 'firebase-admin-sdk'
    #
    # Configuration is read from +RrxConfig.firebase+ (project_id, client_email,
    # private_key, etc.).
    class Firebase < Base
      def id_from_token(id_token)
        require_firebase!
        verified = auth.verify_id_token(id_token)
        verified['sub']
      rescue ::Firebase::Admin::Auth::ExpiredTokenError
        raise TokenExpiredError
      end

      def user_info(uid)
        require_firebase!
        auth.get_user(uid)
      end

      private

      def require_firebase!
        require 'firebase-admin-sdk'
      rescue LoadError
        raise LoadError,
              "firebase-admin-sdk is required for Firebase authentication. " \
              "Add `gem 'firebase-admin-sdk'` to your Gemfile."
      end

      def credentials
        @credentials ||= ::Firebase::Admin::Credentials.from_json(config.to_json)
      end

      def app
        @app ||= begin
          app_config = ::Firebase::Admin::Config.new(
            project_id:         config.project_id,
            service_account_id: config.client_email
          )
          ::Firebase::Admin::App.new(credentials:, config: app_config)
        end
      end

      def auth
        @auth ||= ::Firebase::Admin::Auth::Client.new(app)
      end

      def config
        RrxConfig.firebase
      end
    end
  end
end
