BeijingEmperor::Base.class_eval do
  def to_tokyo_tyrant
    @id || raise(BeijingEmperor::InvalidCoercion)
  end
end
