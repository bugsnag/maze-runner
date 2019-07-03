class Values
  class << self
    def stored_values
      @values ||= {}
    end
  end
end

# Before each test
Before do
  Values.stored_values.clear
end