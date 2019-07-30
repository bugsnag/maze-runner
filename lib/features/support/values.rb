class Store
  class << self
    def values
      @values ||= {}
    end
  end
end

# Before each test
Before do
  Store.stored_values.clear
end