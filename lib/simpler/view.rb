require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      if template.is_a?(Hash)
        type, content = template.first
        send "render_#{type}", content, binding
      else
        render_template(binding)
      end
    end

    private

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def template_path
      path = template || [controller.name, action].join('/')

      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

    def render_template(binding)
      template = File.read(template_path)
      ERB.new(template).result(binding)
    end

    def render_plain(text, _binding)
      text
    end

    def render_inline(inline_string, binding)
      ERB.new(inline_string).result(binding)
    end

  end
end
