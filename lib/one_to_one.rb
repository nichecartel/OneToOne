require 'one_to_one/child'

module OneToOne
  def self.included(base)
    base.class_eval do
    
      class_name = self.class.to_s
      class << self
        alias_method(:original_belongs_to, :belongs_to)
        private :original_belongs_to
        
        attr_accessor :parent_class_name
        
        #hook for setting up Child methods
        def belongs_to(parent)
          raise NoMethodError, "#{class_name} already has a parent class named #{@parent_class_name}" if @parent_class_name
          
          include OneToOne::Child
          set_child_methods(parent)
        end
        
      end
    end
  end
end
