# frozen_string_literal: true
require 'rrx_logging/logger'

describe RrxApi::Controller do
  describe 'railtie' do
    it 'should set application config' do
      get '/test'
      expect(json_response).to include(
                                 time_zone:     'utc',
                                 schema_format: 'sql'
                               )
    end
  end

  describe 'logging' do

    it 'should set current logger' do
      get '/test'
      expect(json_response).to include(
                                 current_logger: true,
                                 logger_class:   'RrxLogging::Logger'
                               )
    end

    it 'should output controller' do
      expect do
        get '/test'
      end.to output(/INFO test: Log!!/).to_stdout
    end

    it 'should output action' do
      expect do
        get '/test'
      end.to output(/Log!!.*\[action=test\]/).to_stdout
    end

    it 'should request ID' do
      expect do
        get '/test'
      end.to output(/Log!!.*\[request_id=\S+\]/).to_stdout
    end
  end
end
