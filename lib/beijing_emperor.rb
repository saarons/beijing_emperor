require "tokyo_tyrant"
require "active_model"
require "active_support/all"

require "beijing_emperor/base"
require "beijing_emperor/errors"
#require "beijing_emperor/callbacks"
require "beijing_emperor/serialization"

BeijingEmperor::Base.class_eval do
  include ActiveModel::Dirty
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
end
