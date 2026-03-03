# frozen_string_literal: true

module RrxApi
  # Controller concern providing authentication plumbing.
  #
  # Include this in your ApplicationController (it is included in RrxApi::Controller
  # by default). Then call +authenticate!+ on any controller that requires auth:
  #
  #   class Api::V1::PostsController < ApplicationController
  #     authenticate!
  #   end
  #
  # Override +authenticated_user+ in your ApplicationController to resolve the
  # current user from the request (token, API key, etc.). The default implementation
  # returns +nil+, which means all requests are unauthenticated unless overridden.
  #
  # In test environments, requests may pass an +X-Test-User-Id+ header instead of
  # a real token. Override +test_user+ if your User model has a different lookup.
  module Authenticatable
    extend ActiveSupport::Concern

    AUTH_HEADER  = 'Authorization'
    BEARER_TOKEN = 'Bearer'

    included do
      rescue_from RrxApi::Auth::TokenExpiredError do
        render json: { error: 'token_expired' }, status: :unauthorized
      end
    end

    class_methods do
      # Prepend a before_action that calls +authenticate_user!+.
      # @param only   [Array<Symbol>, nil]
      # @param except [Array<Symbol>, nil]
      def authenticate!(only: nil, except: nil)
        prepend_before_action :authenticate_user!, only: only, except: except
      end
    end

    # Returns the authenticated user or +nil+.
    # In test env the +X-Test-User-Id+ header short-circuits real auth.
    def current_user
      @current_user ||= (Rails.env.test? ? test_user : nil) || authenticated_user
    end

    private

    # Render 401 unless current_user is present.
    def authenticate_user!
      unauthorized! unless current_user
    end

    # Render a standardised 401 response.
    # @param message [String]
    def unauthorized!(message: 'Not authenticated')
      render json: { error: message }, status: :unauthorized
    end

    # Resolve the current user from the request. Override this in your
    # ApplicationController — e.g. look up by API key or bearer token.
    # @return [Object, nil]
    def authenticated_user
      nil
    end

    # Yields the bearer token string if an +Authorization: Bearer <token>+ header is present.
    def with_bearer_token
      parts = request.headers[AUTH_HEADER]&.split(' ', 2)
      yield parts[1] if parts&.first == BEARER_TOKEN
    end

    # Returns a user identified by the +X-Test-User-Id+ request header.
    # Only active in the test environment. Override if your lookup differs.
    # @return [Object, nil]
    def test_user
      nil
    end
  end
end
