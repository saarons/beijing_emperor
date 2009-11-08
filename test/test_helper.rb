['lib', 'vendor'].each { |x| $:.unshift File.join(File.dirname(__FILE__),'..',x) }

require "test/unit"
require "matchy"
require "beijing_emperor"

Time.zone = "UTC"
BeijingEmperor::Base.setup!

class Bank < BeijingEmperor::Base
  column :name
  column :code, :type => :integer
end

class CreditUnion < Bank
end
