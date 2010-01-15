module OneToOne
  def self.included(base)
    base.class_eval do
    
      class_name = self.class.to_s
      class << self
        alias_method(:original_belongs_to, :belongs_to)
        private :original_belongs_to
        
        attr_accessor :parent_class_name
        
        def belongs_to(parent)
          raise NoMethodError, "#{class_name} already has a parent class named #{@parent_class_name}" if @parent_class_name
          parent_name = parent.to_s
          set_table_name(parent_name.pluralize)
          original_belongs_to(parent)
          @parent_class_name = parent_name.capitalize
          
          validates_presence_of @parent_class_name.downcase
          validate :parent_not_changed, :on => :update
        end
        
        #limits the columns for Child to primary_key and child__* columns
        def columns
          unless defined?(@columns) && @columns
            @columns = connection.columns(table_name, "#{name} Columns").select do |column| 
              column.name =~ Regexp.new("^child__") || column.name == primary_key
            end
            @columns.each { |column| column.primary = column.name == primary_key }
          end
          @columns
        end
        def define_attribute_methods
          super
          self.generated_methods.each do |method|
            if method.to_s =~ Regexp.new("^#{self.to_s.downcase}__")
              puts new_method_name = $~.post_match
              alias_method(new_method_name, method)
              private method
              self.generated_methods << new_method_name
            end
          end
        end
      end
      
# Prevents the child instance from being created without a parent instance     
      def create
        if self.parent.valid?
          self.parent.save!
          self.id = self.parent.id
          self.instance_variable_set(:@new_record, false)
          self.save
        else
          self.errors.add(self.class.parent_class_name.downcase, 'has errors')
        end
      end
      
# Renames the attributes to remove the extra 'child__*' from attribute names
#      def attributes_from_column_definition
#        self.class.columns.inject({}) do |attributes, column|
#          attributes[column.name.gsub(Regexp.new("^#{self.class.to_s.downcase}__"), '')] = column.default unless column.name == self.class.primary_key
#          attributes
#        end
#      end
      
# Renames attributes back to their original column names     
#      def attributes=(new_attributes, guard_protected_attributes = true)
#        return if new_attributes.nil?
#        unaliased_attributes = new_attributes.inject({}) do |attributes, (k,v)| 
#          unaliased_key = "#{self.class.to_s.downcase}__#{k}"
#          unaliased_key = k unless self.class.column_names.include?(unaliased_key)
#          attributes[unaliased_key] = v
#          attributes
#        end
#        return super(unaliased_attributes, guard_protected_attributes)
#      end
      
      private
      def parent_not_changed
        self.errors.add(self.class.parent_class_name.downcase, 'cannot be changed to another') unless self.parent.id == self.id
      end
    end
  end
end
