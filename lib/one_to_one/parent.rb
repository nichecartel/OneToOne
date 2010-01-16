module OneToOne
  module Parent
    def self.included(base)
      def base.set_parent_methods(child)
        self.class_eval do          
          @child_class_name = child.to_s.classify
          @child_association_name = child.to_s
        
          # To replace original has_one functionality
          define_method(child) do
            @child ||= self.class.child_class_name.constantize.find_by_id(self.id)
          end
          define_method("#{child}=") do |child_object|
            @child = child_object
            @child.send("#{self.class.to_s.underscore}=", self)
          end
          
          # To avoid having the attributes hash pick up the extra columns when 
          # the parent is saved for the first time.
          def create(*args)
            ret = super(*args)
            self.reload
            return ret
          end
          
          class << self
            attr_accessor :child_class_name
            attr_accessor :child_association_name
          
            # Limits the columns for Parent to not include child__* columns
            def columns
              unless defined?(@columns) && @columns
                @columns = connection.columns(table_name, "#{name} Columns").reject do |column| 
                  column.name =~ Regexp.new("^#{@child_association_name}__")
                end
                @columns.each { |column| column.primary = column.name == primary_key }
              end
              @columns
            end
          end
        end
      end
    end
  end
end
