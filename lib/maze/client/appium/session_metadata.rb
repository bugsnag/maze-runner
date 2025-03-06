module Maze
  module Client
    module Appium
      class SessionMetadata
        def initialize
          @success = false
          @failure_message = 'Default failure message'
        end

        attr_accessor :id
        attr_accessor :farm
        attr_accessor :device
        attr_accessor :success
        attr_accessor :failure_message
      end
    end
  end
end
