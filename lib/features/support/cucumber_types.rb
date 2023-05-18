ParameterType(
  name:        'request_type',
  regexp:      /errors?|sessions?|builds?|logs?|metrics?|sampling requests?|traces?|uploads?|sourcemaps?|invalid requests?/,
  type:        String,
  transformer: ->(s) { s }
)
