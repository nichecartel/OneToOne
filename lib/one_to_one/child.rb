module OneToOne
  module Child
    def self.included(base)
      def base.set_child_methods(parent)
        self.class_eval do
          parent_name = parent.to_s
          set_table_name(parent_name.pluralize)
          original_belongs_to(parent)
          @parent_class_name = parent_name.to_s.classify
          @parent_association_name = parent_name.to_s
          
          validates_presence_of @parent_association_name
          validate :parent_not_changed, :on => :update
          
          # Prevents the child instance from being created without a parent instance.
          # Reloads the object to avoid having the attributes hash pick up the extra columns 
          # when the child is saved for the first time.             
          def create
            if self.send(self.class.parent_association_name).valid?
              self.send(self.class.parent_association_name).save!
              self.id = self.send(self.class.parent_association_name).id
              self.instance_variable_set(:@new_record, false)
              ret = self.save
              self.reload
              return ret
            else
              self.errors.add(self.class.parent_association_name, 'has errors')
            end
          end         
      
          private
          def parent_not_changed
            unless (self.send(self.class.parent_association_name).id == self.id) or self.id.nil?
              self.errors.add(self.class.parent_association_name, 'cannot be changed to another') 
            end
          end
          
          class << self
            attr_accessor :parent_class_name
            attr_accessor :parent_association_name
          
            # Limits the columns for Child to primary_key and child__* columns
            def columns
              unless defined?(@columns) && @columns
                @columns = connection.columns(table_name, "#{name} Columns").select do |column| 
                  column.name =~ Regexp.new("^#{self.to_s.underscore}__") || column.name == primary_key
                end
                @columns.each { |column| column.primary = column.name == primary_key }
              end
              @columns
            end
            
            # Aliases dynamic attribute methods to remove 'class__' from method name
            def define_attribute_methods
              super
              self.generated_methods.each do |method|
                if method.to_s =~ Regexp.new("^#{self.to_s.underscore}__")
                  new_method_name = $~.post_match
                  alias_method(new_method_name, method)
                  private method
                  self.generated_methods << new_method_name
                end
              end
            end                
          end
          
        end
      end
    end
  end
end
