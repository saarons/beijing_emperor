Range.class_eval do
  def to_tokyo_tyrant
    "#{self.first} #{self.last}"
  end
end
