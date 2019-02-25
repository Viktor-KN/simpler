require 'logger'

class HttpLogger
  def initialize(app)
    @app = app
    @logger = Logger.new(Simpler.root.join('log/app.log'))
  end

  def call(env)
    @request = Rack::Request.new(env)
    @response = @app.call(env)
    log
    @response
  end

  private

  def log
    buffer = "\nRequest: #{request_method} #{request_path_and_query}\n"
    buffer += "Handler: #{handler}##{action}\n"
    buffer += "Parameters: #{request_params}\n"
    buffer += "Response: #{response_status} [#{response_content_type}] #{template}"

    @logger.info buffer
  end

  def request_method
    @request.request_method
  end

  def request_path_and_query
    if @request.query_string.empty?
      @request.path_info
    else
      [@request.path_info, @request.query_string].join('?')
    end
  end

  def handler
    @request.env['simpler.controller'].class.name
  end

  def action
    @request.env['simpler.action']
  end

  def request_params
    @request.params.merge(@request.env['simpler.route_params'])
  end

  def response_status
    [@response[0], Rack::Utils::HTTP_STATUS_CODES[@response[0]]].join(' ')
  end

  def response_content_type
    @response[1]['Content-Type']
  end

  def template
    return "custom: #{@request.env['simpler.template'].keys[0]}" if @request.env['simpler.template'].is_a?(Hash)

    path = @request.env['simpler.template'] ||
           [@request.env['simpler.controller'].name, @request.env['simpler.action']].join('/')
    "#{path}.html.erb"
  end
end
