ParameterType(
  name:        'request_type',
  regexp:      /errors?|sessions?|builds?|logs?|metrics?|sampling requests?|traces?|uploads?|sourcemaps?|invalid requests?/,
  type:        String,
  transformer: ->(s) { s }
)

ParameterType(
  name:        'int_array',
  regexp:      /\d+(?:, ?\d+)+/,
  type:        String,
  transformer: ->(s) { s.split(',').map(&:strip).map(&:to_i) }
)
