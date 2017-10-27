require "active_support/dependencies"
require "constant_record/version"

module ConstantRecord
  extend ActiveSupport::Autoload
  autoload :Base
end
