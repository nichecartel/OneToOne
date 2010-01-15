module OneToOne
  module Parent
    def self.included(base)
      def base.set_parent_methods(child)
        self.class_eval do
          original_has_one(child)
          
          @child_class_name = child.to_s.capitalize
          
          #to avoid having the attributes hash pick up the extra columns when the parent is saved for the first time
          def create(*args)
            ret = super(*args)
            self.reload
            return ret
          end
          
          class << self
            # Limits the columns for Parent to not include child__* columns
            def columns
              unless defined?(@columns) && @columns
                @columns = connection.columns(table_name, "#{name} Columns").reject do |column| 
                  column.name =~ Regexp.new("^#{@child_class_name.downcase}__")
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
