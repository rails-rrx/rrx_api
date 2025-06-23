# frozen_string_literal: true

require_relative 'rrx_api/version'
require_relative 'rrx_api/engine'
require 'rrx_config'
require 'rrx_logging'
require 'rack/cors'

module RrxApi
  class Error < StandardError; end
  # Your code goes here...
end
