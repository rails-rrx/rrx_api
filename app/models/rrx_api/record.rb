# frozen_string_literal: true

module RrxApi
  class Record < ActiveRecord::Base
    self.abstract_class = true

    before_create :set_new_id

    # @return [RrxLogging::Logger]
    def logger
      @logger ||= RrxLogging.current || Rails.logger
    end

    protected

    def set_new_id
      self.id ||= Random.uuid if has_attribute?(:id)
    end

  end

end
