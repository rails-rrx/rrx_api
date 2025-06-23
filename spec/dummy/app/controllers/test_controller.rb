# frozen_string_literal: true
require 'rrx_logging'

class TestController < ApplicationController
  helper_method :some_helper

  def test
    logger.info 'Log!!!'
    render json: {
      current_logger: !!RrxLogging.current,
      logger_class:   Rails.logger.class.name,
      time_zone:      Rails.application.config.time_zone,
      schema_format:  Rails.application.config.active_record.schema_format
    }
  end

  def some_helper
    'foo'
  end
end
