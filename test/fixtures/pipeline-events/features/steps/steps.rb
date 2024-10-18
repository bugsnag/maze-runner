When('I send a request to the server') do
  test_payload = JSON.generate({
    apiKey: ENV['MAZE_REPEATER_API_KEY'],
    notifier: {
      name: 'Ruby Bugsnag Notifier',
      version: '6.27.1',
      url: 'https://www.bugsnag.com'
    },
    payloadVersion: '4.0',
    events: [
      {
        app: { version: nil, releaseStage: nil, type: nil },
        breadcrumbs: [],
        device: {
          hostname: 'SBUK62MMD6T.local',
          runtimeVersions: { ruby: '3.3.5' },
          time: '2024-10-17T14:27:33.829Z'
        },
        exceptions: [
          {
            errorClass: 'RuntimeError',
            message: 'This is an error',
            stacktrace: [
              {
                lineNumber: 435,
                file: 'gems/bugsnag-6.27.1/lib/bugsnag/report.rb',
                method: 'block in generate_exception_list',
                code: {
                  '432': '        {',
                  '433': '          errorClass: class_name,',
                  '434': '          message: error_message(exception, class_name),',
                  '435': '          stacktrace: Stacktrace.process(exception.backtrace, configuration)',
                  '436': '        }',
                  '437': '      end',
                  '438': '    end'
                }
              }
            ]
          }
        ],
        featureFlags: [],
        metaData: {},
        severity: 'warning',
        severityReason: { type: 'handledException' },
        unhandled: false,
        user: {}
      }
    ]
  })

  http = Net::HTTP.new('localhost', '9339')
  request = Net::HTTP::Post.new('/notify')
  request['content-type'] = 'application/json'
  request['bugsnag-api-key'] = ENV['MAZE_REPEATER_API_KEY']
  request['bugsnag-payload-version'] = '4.0'
  request['bugsnag-sent-at'] = Time.now.utc.iso8601
  request.body = test_payload

  http.request(request)
end