# frozen_string_literal: true

require_relative '../helper'
require_relative 'validator_base'

module Maze
  module Schemas
    class ConfigValidator < ValidatorBase

      attr_accessor :success
      attr_accessor :errors
      attr_reader :headers
      attr_reader :body

      def initialize(request, validation_block)
        super(request)
        @validation_block = validation_block
      end

      def validate
        @success = true
        @validation_block.call(self)
      rescue => exception
        @success = false
        @errors << "A #{exception.class} occurred while running validation: #{exception.message}"
      end
    end
  end
end
