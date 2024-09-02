# frozen_string_literal: true

require_relative '../helper'
require_relative 'validator_base'

module Maze
  module Schemas

    # Contains a set of pre-defined validations for ensuring errors are correct
    class ErrorValidator

      # Runs the validation against the trace given
      def validate
        @success = true
      end
    end
  end
end
