['lib', 'vendor'].each { |dir| $:.unshift File.join(File.dirname(__FILE__),'..',dir) }

require "beijing_emperor"

Time.zone = "UTC"
BeijingEmperor::Base.setup!

class Bank < BeijingEmperor::Base
  column :name
  column :code, :type => :integer
  validates_presence_of :name
end

class CreditUnion < Bank
end
