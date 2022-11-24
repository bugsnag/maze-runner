# frozen_string_literal: true

module Maze
  module Schemas
    TRACE_SCHEMA = JSON.parse(File.read(File.expand_path("TracesData-temp.json", File.dirname(__FILE__))))
  end
end