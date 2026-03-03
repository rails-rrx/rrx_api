# frozen_string_literal: true

describe 'Authenticatable' do
  include_context :auth_helpers

  let(:user) { OpenStruct.new(id: '42') }

  describe '#current_user' do
    it 'returns nil when no auth header and no test user header' do
      get '/open'
      expect(response).to be_successful
      expect(json_response[:authenticated]).to be false
    end

    it 'returns the test user when X-Test-User-Id header is present' do
      get '/protected_action', headers: { 'X-Test-User-Id' => '42' }
      expect(response).to be_successful
      expect(json_response[:user_id]).to eq '42'
    end
  end

  describe '#authenticate!' do
    it 'returns 401 when no user is present' do
      get '/protected_action'
      expect(response).to have_http_status(:unauthorized)
      expect(json_error[:error]).to eq 'Not authenticated'
    end

    it 'allows access when X-Test-User-Id header is present' do
      get '/protected_action', headers: { 'X-Test-User-Id' => '42' }
      expect(response).to be_successful
    end

    it 'skips auth for exempt actions' do
      get '/open'
      expect(response).to be_successful
    end
  end

  describe 'TokenExpiredError rescue' do
    it 'renders 401 with token_expired error when token is expired' do
      get '/token_expired_action', headers: { 'X-Test-User-Id' => '42' }
      expect(response).to have_http_status(:unauthorized)
      expect(json_error[:error]).to eq 'token_expired'
    end
  end

  describe 'authenticated! class helper' do
    context 'without authenticated! hook' do
      it 'does not set auth headers by default' do
        get '/protected_action'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authenticated! hook' do
      authenticated!

      it 'sets X-Test-User-Id from user let' do
        get '/protected_action', headers: request_headers
        expect(response).to be_successful
        expect(json_response[:user_id]).to eq user.id
      end
    end
  end
end
