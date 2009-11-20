$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require "beijing_emperor"

Time.zone = "UTC"
BeijingEmperor::Base.setup!

class Bank < BeijingEmperor::Base
  column :name
  column :code, :type => :integer
  validates_presence_of :name
  validates_inclusion_of :code, :within => 1..4
end

class CreditUnion < Bank
end
