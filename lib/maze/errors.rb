module Maze
  module Error
    # An error raised when an appium element cannot be found
    class AppiumElementNotFoundError < StandardError

      # @# @!attribute [r] element
      #   @return [String] The named element that could not be found
      attr_reader :element

      # Creates the error
      #
      # @param message [String] The error to display
      # @param element [String] The name of the element that could not be located
      def initialize(message='Element not found', element='No element specified')
        @element = element
        super(message)
      end
    end
  end
end