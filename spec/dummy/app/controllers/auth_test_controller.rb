# frozen_string_literal: true

class AuthTestController < ApplicationController
  authenticate! except: :open

  def open
    render json: { authenticated: false }
  end

  def protected_action
    render json: { authenticated: true, user_id: current_user&.id }
  end

  def token_expired_action
    raise RrxApi::Auth::TokenExpiredError
  end

  private

  def test_user
    id = request.headers['X-Test-User-Id']
    return nil unless id

    OpenStruct.new(id: id)
  end
end
