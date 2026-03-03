# frozen_string_literal: true

module RrxApi
  module Auth
    class TokenExpiredError < StandardError
      def initialize
        super('User token expired')
      end
    end

    # Abstract authentication provider base class.
    # Subclass and override {#id_from_token} (and optionally {#user_info}) to implement a provider.
    class Base
      # Verify a bearer token and return the provider user ID.
      # @param _token [String]
      # @return [String]
      def id_from_token(_token)
        raise NotImplementedError, "#{self.class}#id_from_token is not implemented"
      end

      # Fetch user info for a given provider UID (optional).
      # @param _uid [String]
      # @return [Object, nil]
      def user_info(_uid)
        nil
      end
    end
  end
end
