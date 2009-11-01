module BeijingEmperor
  class Base
    OPERATORS = { '==' => TokyoTyrant::Query::CSTREQ,
                  '!=' => TokyoTyrant::Query::CSTREQ | TokyoTyrant::Query::CNEGATE,
                  '=~' => TokyoTyrant::Query::CSTRRX,
                  '!~' => TokyoTyrant::Query::CSTRRX | TokyoTyrant::Query::CNEGATE,
                  '>'  => TokyoTyrant::Query::CNUMGT,
                  '>=' => TokyoTyrant::Query::CNUMGE,
                  '<'  => TokyoTyrant::Query::CNUMLT,
                  '<=' => TokyoTyrant::Query::CNUMLE,
                  '><' => TokyoTyrant::Query::CNUMBT,
                  '<>' => TokyoTyrant::Query::CNUMBT | TokyoTyrant::Query::CNEGATE
                }
                 
    DEFAULT_TYPES = { :string   => "String",
                      :datetime => "ActiveSupport::TimeWithZone",
                      :integer  => "Integer"
                    }
    
    attr_reader                :id
    attr_reader                :attributes
    class_inheritable_accessor :columns
    class_inheritable_accessor :database
    self.columns               = Hash.new.with_indifferent_access

    class << self
      def friendly_name
        model_name.element
      end

      def fields(*cols)
        options = cols.extract_options!
        cols.reject{ |x| x == :id || self.columns.include?(x) }.each do |col|
          self.columns[col] = options[:type] || :string
          send :define_method, col do
            @attributes[col]
          end
          send :define_method, "#{col}=" do |value|
            @attributes[col] = value
          end
        end
      end

      def setup!(spec = {})
        return if self.database
        config = { address: "127.0.0.1", port: 1978 }
        config.merge!(spec)
        self.database = TokyoTyrant::Table.new(config[:address], config[:port])
      end

      def find(*args)
        options = args.extract_options!
        case args.first
          when :first then find_initial(options)
          when :last  then find_last(options)
          when :all   then find_every(options)
          else             find_from_ids(args, options)
        end
      end
      
      def all(*args)
        find(:all, *args)
      end

      private
      def find_from_ids(ids, options)
        expects_array = ids.first.kind_of?(Array)
        return ids.first if expects_array && ids.first.empty?

        ids = ids.flatten.compact.uniq

        case ids.size
          when 0
            raise(BeijingEmperor::RecordNotFound)
          when 1
            result = find_one(ids.first, options)
            expects_array ? [ result ] : result
          else
            find_some(ids, options)
        end
      end

      def find_one(id, options)
        if result = self.database.get(id)
          instantiate(result.merge( { :__id => id } ))
        else
          raise(BeijingEmperor::RecordNotFound)
        end
      end

      def find_initial(options)
        options.update(:limit => 1)
        find_every(options).first
      end

      def find_last(options)
        options.update(:order => :numdesc)
        find_initial(options)
      end

      def find_some(ids, options)
        result = self.database.mget(ids)
        if result.size == ids.size
          result.collect { |x| instantiate(x[1].merge(:__id => x[0])) }
        else
          raise(BeijingEmperor::RecordNotFound)
        end
      end

      def find_every(options)
        query      = self.database.query
        conditions = options[:conditions] || {}
        limit      = options[:limit]      || -1
        order      = options[:order]      || :numasc

        # Ensure that the objects found are of the finding class.
        # e.g. Bank.find(:all) returns all objects that have a key starting
        # with "bank".
        query.condition("", :strrx, class_regex.source)
        
        query.limit(limit)
        query.order_by("created_at", order)
        conditions.each_pair do |field, value|
          query.condition(*build_condition(field, value))
        end

        query.get.map { |record| instantiate(record) }
      end
      
      def build_condition(field, value)
        case value
        when Array
          operator = OPERATORS[value[0].to_s]
          value    = value[1]
        when Regexp
          operator = OPERATORS["=~"]
        when Range
          operator = OPERATORS["><"]
        else
          operator = OPERATORS["=="]
        end

        # workaround method for equal integers
        if [:integer].include?(self.columns[field]) && operator == OPERATORS["=="]
          operator = TokyoTyrant::Query::CNUMEQ
        end

        value = value.respond_to?(:to_tokyo_tyrant) ? value.to_tokyo_tyrant : value.to_s
        [field.to_s, operator, value]
      end

      def class_regex
        @_class_regex ||= /^#{friendly_name}_[a-z0-9]{6}$/
      end

      def instantiate(attributes)
        attributes = attributes.with_indifferent_access

        record = self.allocate
        record.instance_variable_set(:@id, attributes.delete(:__id).to_s)
        record.instance_variable_set(:@attributes, Hash.new.with_indifferent_access)
        record.send :load_from_database, attributes
        record
      end
    end

    fields :created_at, :updated_at, :type => :datetime

    def initialize(attributes = {})
      @new_record = true
      @attributes = Hash.new.with_indifferent_access
      load_from_hash(attributes)
      yield self if block_given?
    end

    def ==(other)
      case other
        when self.class then @attributes == other.attributes && @id == other.id
        else                 false
      end
    end
    
    def save
      create_or_update
    end
    
    def save!
      save || raise(BeijingEmperor::RecordNotSaved)
    end

    def new_record?
      @new_record || false
    end

    def destroyed?
      @destroyed || false
    end

    def destroy
      unless new_record? || destroyed?
        @destroyed = db.out(@id)
      else
        false
      end
    end
  
    private
    def from_tokyo_tyrant(value, type)
      klass = (DEFAULT_TYPES.include?(type) ? DEFAULT_TYPES[type] : type.to_s).constantize
      klass.respond_to?(:from_tokyo_tyrant) ? klass.from_tokyo_tyrant(value) : klass.new(value)
    end

    def load_from_database(attributes)
      attributes.each_pair { |k, v| send("#{k}=", from_tokyo_tyrant(v, self.class.columns[k])) if respond_to?("#{k}=") }
    end

    def db
      @db ||= self.class.database
    end
    
    def create
      loop do
        id = "#{self.class.friendly_name}_#{rand(36**8).to_s(36)[0..5]}"
        if db.get(id) == nil
          @id = id
          break
        end  
      end
      if _database_update!
        @new_record = false
        true
      else
        false
      end
    end
    
    def update
      _database_update!
    end
    
    def create_or_update
      if valid? && !destroyed?
        new_record? ? create : update
      else
        false
      end
    end
    
    def _database_update!
      now = Time.zone.at(Time.zone.now.to_i)
      timestamps = {:updated_at => now}
      timestamps.merge!(:created_at => now) if new_record?
      
      modified_attributes = @attributes.merge(timestamps)
      if db.put(@id, modified_attributes)
        @attributes = modified_attributes
        true
      else
        false
      end
    end

    def load_from_hash(attributes)
      attributes.each_pair { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

  end
end
