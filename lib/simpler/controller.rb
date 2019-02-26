require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      merge_params
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def merge_params
      @request.env['simpler.all_params'] = @request.params.merge(@request.env['simpler.route_params'])
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.env['simpler.all_params']
    end

    def render(template)
      set_render_params(template) if template.is_a?(Hash)

      @request.env['simpler.template'] = template
    end

    def status(code)
      response.status = code.to_i
    end

    def headers
      @response.headers
    end

    def set_render_params(template)
      case template.keys[0]
      when :plain
        headers['Content-Type'] = 'text/plain'
      end
    end
  end
end
