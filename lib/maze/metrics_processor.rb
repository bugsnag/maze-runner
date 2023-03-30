require_relative './request_list'

module Maze
  class MetricsProcessor
    # @param metrics [RequestList] The metrics to be processed
    def initialize(metrics)
      @metrics = metrics
      @columns = Set.new
      @rows = []
    end

    # Collates the metrics given into a CSV-friendly structure and writes the CSV to disk
    def process
      return if @metrics.size_all == 0

      collate
      write_to_disk
    end

    # Organises the raw metrics into an Array of hashes representing each row of the CSV,
    # whilst also capturing an overall set of column headings
    def collate
      @metrics.all.each do |metric|
        row = {}
        metric.each do |key, value|
          @columns.add key
          row[key] = value
        end
        @rows << row
      end
    end

    def write_to_disk
      filepath = File.join(Dir.pwd, 'maze_output', 'metrics.csv')

      puts "Call with #{filepath}"

      File.open(filepath, 'w') do |file|
        # Write the header, with columns ordered alphabetically
        sorted_columns = @columns.to_a.sort
        header = sorted_columns.join ','
        file.puts header

        # Write the rows
        @rows.each do |row|
          row_values = []
          sorted_columns.each do |column|
            add = if row.has_key? column
                    "#{to_csv_friendly(row[column])}"
                  else
                    ''
                  end
            row_values << add
            end

          file.puts row_values.join ','
        end
      end
    end

    def to_csv_friendly(value)
      return value unless value.class == String

      if value.include?(' ') || value.include?(',')
        "\"#{value}\""
      else
        value
      end
    end

  end
end
