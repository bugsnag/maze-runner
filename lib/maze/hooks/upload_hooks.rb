module Maze
  module Hooks
    # Hooks for Upload mode use
    class UploadHooks < InternalHooks
      def before_all
        config = Maze.config
        config.app = Maze::BrowserStackUtils.upload_app config.username,
                                                        config.access_key,
                                                        config.app,
                                                        config.app_id_file
      end
    end
  end
end