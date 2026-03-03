# frozen_string_literal: true

describe RrxApi::Engine, '.cors_origin_allowed?' do
  def allowed?(source, configured)
    described_class.cors_origin_allowed?(source, configured)
  end

  context 'with exact string origins' do
    it 'allows an exact match' do
      expect(allowed?('https://app.example.com', ['https://app.example.com'])).to be true
    end

    it 'rejects a non-matching origin' do
      expect(allowed?('https://evil.com', ['https://app.example.com'])).to be false
    end
  end

  context 'with wildcard subdomain origins (*.example.com)' do
    it 'allows any subdomain' do
      expect(allowed?('https://foo.example.com', ['*.example.com'])).to be true
    end

    it 'allows nested subdomains' do
      expect(allowed?('https://api.v2.example.com', ['*.example.com'])).to be true
    end

    it 'rejects a different domain' do
      expect(allowed?('https://evil.example.org', ['*.example.com'])).to be false
    end
  end

  context 'with Regexp origins' do
    it 'allows origins matching the pattern' do
      expect(allowed?('https://staging.example.com', [/\Ahttps:\/\/.*\.example\.com\z/])).to be true
    end

    it 'rejects origins not matching the pattern' do
      expect(allowed?('https://evil.com', [/\Ahttps:\/\/.*\.example\.com\z/])).to be false
    end
  end

  context 'with a mix of types' do
    let(:configured) do
      [
        'https://app.example.com',
        '*.staging.example.com',
        /\Ahttps:\/\/preview-\d+\.example\.com\z/
      ]
    end

    it 'allows an exact match' do
      expect(allowed?('https://app.example.com', configured)).to be true
    end

    it 'allows a wildcard subdomain match' do
      expect(allowed?('https://branch.staging.example.com', configured)).to be true
    end

    it 'allows a regex match' do
      expect(allowed?('https://preview-42.example.com', configured)).to be true
    end

    it 'rejects an unmatched origin' do
      expect(allowed?('https://evil.com', configured)).to be false
    end
  end

  context 'with an empty origins list' do
    it 'rejects all origins' do
      expect(allowed?('https://app.example.com', [])).to be false
    end
  end
end
