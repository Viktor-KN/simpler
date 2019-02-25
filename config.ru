require_relative 'config/environment'
require_relative 'lib/http_logger'

use HttpLogger

run Simpler.application
