# frozen_string_literal: true

require 'rrx_api/auth/firebase'

describe RrxApi::Auth::Firebase do
  subject(:provider) { described_class.new }

  describe '#id_from_token' do
    context 'when firebase-admin-sdk is not installed' do
      before do
        allow(provider).to receive(:require).with('firebase-admin-sdk').and_raise(LoadError)
      end

      it 'raises a descriptive LoadError' do
        expect { provider.id_from_token('any') }
          .to raise_error(LoadError, /firebase-admin-sdk is required for Firebase authentication/)
      end

      it 'mentions how to fix the issue' do
        expect { provider.id_from_token('any') }
          .to raise_error(LoadError, /gem 'firebase-admin-sdk'/)
      end
    end

    context 'when firebase-admin-sdk is available' do
      let(:fake_auth)  { double('Firebase::Admin::Auth::Client') }
      let(:verified)   { { 'sub' => 'firebase-uid-123' } }

      before do
        allow(provider).to receive(:require).with('firebase-admin-sdk')
        allow(provider).to receive(:auth).and_return(fake_auth)
      end

      it 'returns the user sub from a valid token' do
        allow(fake_auth).to receive(:verify_id_token).with('valid_token').and_return(verified)
        expect(provider.id_from_token('valid_token')).to eq 'firebase-uid-123'
      end

      it 'maps Firebase::Admin::Auth::ExpiredTokenError to TokenExpiredError' do
        expired_error = double('ExpiredTokenError')

        # Stub the Firebase namespace used inside firebase.rb
        firebase_ns = double('Firebase::Admin::Auth')
        stub_const('Firebase::Admin::Auth::ExpiredTokenError', Class.new(StandardError))

        allow(fake_auth).to receive(:verify_id_token)
          .and_raise(Firebase::Admin::Auth::ExpiredTokenError)

        expect { provider.id_from_token('expired_token') }
          .to raise_error(RrxApi::Auth::TokenExpiredError)
      end
    end
  end

  describe '#user_info' do
    context 'when firebase-admin-sdk is not installed' do
      before do
        allow(provider).to receive(:require).with('firebase-admin-sdk').and_raise(LoadError)
      end

      it 'raises a descriptive LoadError' do
        expect { provider.user_info('uid') }
          .to raise_error(LoadError, /firebase-admin-sdk is required/)
      end
    end
  end
end
