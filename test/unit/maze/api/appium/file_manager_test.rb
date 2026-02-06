require 'appium_lib_core'

require_relative '../../../test_helper'
require_relative '../../../../../lib/maze'
require_relative '../../../../../lib/maze/api/appium/file_manager'

module Maze
  module Api
    module Appium
      class FileManagerTest < Test::Unit::TestCase

        def setup()
          $logger = mock('logger')
          @mock_driver = mock('driver')
          Maze.driver = @mock_driver
          @manager = Maze::Api::Appium::FileManager.new
        end

        def test_write_app_file_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot write file to device - Appium driver failed.")

          @manager.write_app_file('contents', 'filename.json')
        end

        def test_write_app_file_success
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:app_id).returns('app1')
          Maze::Helper.expects(:get_current_platform).returns('ios')
          $logger.expects(:trace).with("Pushing file to '@app1/Documents/filename.json' with contents: contents")
          @mock_driver.expects(:push_file).with('@app1/Documents/filename.json', 'contents')

          assert_true(@manager.write_app_file('contents', 'filename.json'))
        end

        def test_write_app_file_failure
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:app_id).returns('app1')
          Maze::Helper.expects(:get_current_platform).returns('ios')
          $logger.expects(:trace).with("Pushing file to '@app1/Documents/filename.json' with contents: contents")
          @mock_driver.expects(:push_file).with('@app1/Documents/filename.json', 'contents').raises(Selenium::WebDriver::Error::UnknownError, 'error')
          $logger.expects(:error).with("Error writing file to device: error")

          assert_false(@manager.write_app_file('contents', 'filename.json'))
        end

        def test_read_app_folder_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot read folder from device - Appium driver failed.")

          @manager.read_app_folder
        end

        def test_read_app_folder_success
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:app_id).returns('app1')
          Maze::Helper.expects(:get_current_platform).returns('android')
          $logger.expects(:trace).with("Attempting to read folder from '/sdcard/Android/data/app1'")
          @mock_driver.expects(:pull_folder).returns('contents')

          assert_equal('contents', @manager.read_app_folder)
        end

        def test_read_app_folder_failure
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:app_id).returns('app1')
          Maze::Helper.expects(:get_current_platform).returns('android')
          $logger.expects(:trace).with("Attempting to read folder from '/sdcard/Android/data/app1'")
          @mock_driver.expects(:pull_folder).raises(Selenium::WebDriver::Error::UnknownError, 'error')

          $logger.expects(:error).with("Error reading folder from device: error")

          assert_nil(@manager.read_app_folder)
        end

        def test_read_app_file_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot read file from device - Appium driver failed.")

          @manager.read_app_file('filename.json')
        end

        def test_read_app_file_success
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:app_id).returns('app1')
          Maze::Helper.expects(:get_current_platform).returns('ios')
          $logger.expects(:trace).with("Attempting to read file from '@app1/Documents/filename.json'")
          @mock_driver.expects(:pull_file).with('@app1/Documents/filename.json').returns('contents')

          assert_equal('contents', @manager.read_app_file('filename.json'))
        end

        def test_read_app_file_failure
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:app_id).returns('app1')
          Maze::Helper.expects(:get_current_platform).returns('ios')
          $logger.expects(:trace).with("Attempting to read file from '@app1/Documents/filename.json'")
          @mock_driver.expects(:pull_file).with('@app1/Documents/filename.json').raises(Selenium::WebDriver::Error::UnknownError, 'error')

          $logger.expects(:error).with("Error reading file from device: error")

          assert_nil(@manager.read_app_file('filename.json'))
        end
      end
    end
  end
end
