module OneToOne
  def self.included(base)
    base.class_eval do
      class_name = self.class.to_s
      class << self
        alias_method(:original_belongs_to, :belongs_to)
        private :original_belongs_to
        
        def belongs_to(parent)
          raise NoMethodError, "#{class_name} already has a parent class named #{@parent_class_name}" if @parent_class_name
          parent_name = parent.to_s
          set_table_name(parent_name.pluralize)
          original_belongs_to(parent)
          @parent_class_name = parent_name.capitalize
        end
      end
      validates_presence_of :parent
    end
  end
end
