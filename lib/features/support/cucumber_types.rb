ParameterType(
  name:        'request_type',
  regexp:      /errors?|sessions?|builds?|logs?|metrics?|sampling requests?|traces?|uploads?|sourcemaps?|reflects?|reflections?|invalid requests?/,
  type:        String,
  transformer: ->(s) { s }
)

ParameterType(
  name:        'orientation',
  regexp:      /portrait|landscape/,
  type:        String,
  transformer: ->(s) { s.to_sym }
)

ParameterType(
  name:        'int_array',
  regexp:      /\d+(?:, ?\d+)*/,
  type:        String,
  transformer: ->(s) { s.split(',').map(&:strip).map(&:to_i) }
)

ParameterType(
  name:        'boolean',
  regexp:      /true|false/,
  type:        Word,
  transformer: ->(s) { s.eql?('true') }
)