require 'ronn'
require 'rack'
require 'sinatra/base'

module Ronn
  # Ronn HTTP server. Serves a list of .ronn files as HTML. The options Hash is
  # passed to Ronn::Document.new on each invocation.
  #
  # Use Ronn::Server.new to create a Rack app. See the config.ru file in the
  # root of the Ronn distribution for example usage.
  #
  # Ronn::Server.run starts a server on port 1207.
  module Server
    def self.new(files, options = {})
      files = Dir[files] if files.respond_to?(:to_str)
      raise ArgumentError, 'no files' if files.empty?
      Sinatra.new do
        set :show_exceptions, true
        set :public_dir, File.expand_path(__FILE__, '../templates')
        set :static, false
        set :views, File.expand_path(__FILE__, '../templates')

        get '/' do
          files.map do |f|
            base = File.basename(f, '.ronn')
            "<li><a href='./#{base}.html'>#{escape_html(base)}</a></li>"
          end
        end

        options[:styles] ||= options[:style]
        my_styles = if options[:styles].respond_to?(:to_ary)
                      options[:styles]
                    elsif options[:styles]
                      options[:styles].split(/[, ]+/)
                    else
                      []
                    end

        files.each do |file|
          basename = File.basename(file, '.ronn')

          get "/#{basename}.html" do
            options = options.merge(styles: my_styles)
            %w[date manual organization].each do |attribute|
              next unless params[attribute]
              options[attribute] = params[attribute]
            end
            Ronn::Document.new(file, options).to_html
          end
          get "/#{basename}.roff" do
            content_type 'text/plain+roff'
            Ronn::Document.new(file, options.dup).to_roff
          end
        end
      end
    end

    def self.run(files, options = {})
      port_number = options['port'] || 1207
      new(files, options).run!(
        server:  %w[mongrel thin webrick],
        port:    port_number,
        logging: true
      )
    end
  end
end
