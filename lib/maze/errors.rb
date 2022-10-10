# frozen_string_literal: true

require 'appium_lib'

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

    ERROR_CODES = {
      ::Selenium::WebDriver::Error::UnknownError => {
        retry: true,
        error_code: 10
      },
      ::Selenium::WebDriver::Error::WebDriverError => {
        retry: true,
        error_code: 10
      },
      Maze::Error::AppiumElementNotFoundError => {
        retry: true,
        error_code: 11
      },
      ::Selenium::WebDriver::Error::NoSuchElementError => {
        retry: true,
        error_code: 12
      },
      ::Selenium::WebDriver::Error::TimeoutError => {
        retry: true,
        error_code: 13
      },
      ::Selenium::WebDriver::Error::StaleElementReferenceError => {
        retry: true,
        error_code: 14
      },
    }.freeze

  end
end