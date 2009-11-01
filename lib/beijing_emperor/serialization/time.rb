ActiveSupport::TimeWithZone.class_eval do
  def self.from_tokyo_tyrant(v)
    Time.zone.at(v.to_i)
  end
  
  def to_tokyo_tyrant
    self.to_i.to_s
  end
end
