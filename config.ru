#\ -p 1207
$LOAD_PATH << File.expand_path('lib', __dir__)

require 'ronn'
require 'ronn/server'

# use Rack::Lint

options = {
  styles: %w[man toc],
  organization: "Ronn v#{Ronn::VERSION}"
}
files = Dir['man/*.ronn'] + Dir['test/*.ronn']

run Ronn::Server.new(files, options)
