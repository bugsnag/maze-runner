# frozen_string_literal: true

require_relative '../helper'
require_relative 'validator_base'

module Maze
  module Schemas
    class ConfigValidator < ValidatorBase
      def initialize(request, validation_block)
        super(request)
        @validation_block = validation_block
      end

      def validate
        @success = true
        @validation_block.call(self)
      end
    end
  end
end
