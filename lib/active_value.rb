require "active_support/dependencies/autoload"
require "active_support/core_ext"
require "active_value/version"

module ActiveValue
  extend ActiveSupport::Autoload
  autoload :Base
end
