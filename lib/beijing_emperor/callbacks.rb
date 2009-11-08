module BeijingEmperor
  module Callbacks
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    included do
      [:create_or_update, :valid?, :create, :update, :destroy].each do |method|
        alias_method_chain method, :callbacks
      end
      define_callbacks :save, :create, :update, :destroy, :validation, :terminator => "result == false", :scope => [:kind, :name]
    end

    module ClassMethods
      [:save, :create, :update, :destroy].each do |callback|
        module_eval <<-CALLBACKS, __FILE__, __LINE__
          def before_#{callback}(*args, &block)
            set_callback(:#{callback}, :before, *args, &block)
          end

          def around_#{callback}(*args, &block)
            set_callback(:#{callback}, :around, *args, &block)
          end

          def after_#{callback}(*args, &block)
            options = args.extract_options!
            options[:prepend] = true
            options[:if] = Array(options[:if]) << "!halted && value != false"
            set_callback(:#{callback}, :after, *(args << options), &block)
          end
        CALLBACKS
      end

      def before_validation(*args, &block)
        options = args.extract_options!
        if options[:on]
          options[:if] = Array(options[:if])
          options[:if] << "@_on_validate == :#{options[:on]}"
        end
        set_callback(:validation, :before, *(args << options), &block)
      end

      def after_validation(*args, &block)
        options = args.extract_options!
        options[:if] = Array(options[:if])
        options[:if] << "!halted"
        options[:if] << "@_on_validate == :#{options[:on]}" if options[:on]
        options[:prepend] = true
        set_callback(:validation, :after, *(args << options), &block)
      end

    end
    def create_or_update_with_callbacks
      _run_save_callbacks do
        create_or_update_without_callbacks
      end
    end
    private :create_or_update_with_callbacks

    def create_with_callbacks
      _run_create_callbacks do
        create_without_callbacks
      end
    end
    private :create_with_callbacks

    def update_with_callbacks(*args)
      _run_update_callbacks do
        update_without_callbacks(*args)
      end
    end
    private :update_with_callbacks

    def valid_with_callbacks?
      @_on_validate = new_record? ? :create : :update
      _run_validation_callbacks do
        valid_without_callbacks?
      end
    end

    def destroy_with_callbacks
      _run_destroy_callbacks do
        destroy_without_callbacks
      end
    end

  end
end
