require 'one_to_one/child'
require 'one_to_one/parent'

module OneToOne
  def self.included(base)
    base.class_eval do
    
      class_name = self.class.to_s
      class << self
        alias_method(:original_belongs_to, :belongs_to)
        private :original_belongs_to
        alias_method(:original_has_one, :has_one)
        private :original_has_one
        
        attr_accessor :parent_class_name
        
        #hook for setting up Child methods
        def belongs_to(parent)
          raise NoMethodError, "#{class_name} already has a parent class named #{@parent_class_name}" if @parent_class_name
          
          include OneToOne::Child
          set_child_methods(parent)
        end
        
        #hook for setting up Parent methods
        def has_one(child)          
          include OneToOne::Parent
          set_parent_methods(child)
        end
        
      end
    end
  end
end
