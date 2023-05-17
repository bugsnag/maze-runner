ParameterType(
  name:        'request_type',
  regexp:      /error(s)|session(s)|build(s)|log(s)|metric(s)|sampling request(s)|trace(s)|upload(s)|sourcemap(s)|invalid request(s)/,
  type:        String,
  transformer: ->(s) { s }
)
