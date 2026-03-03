# frozen_string_literal: true

RSpec.describe RrxApi do
  it "has a version number" do
    expect(RrxApi::VERSION).not_to be nil
  end

  it 'exposes the gem version' do
    expect(RrxApi::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
