module OneToOne
  def self.included(base)
    base.class_eval do
      class << self
        alias_method(:original_belongs_to, :belongs_to)
        private :original_belongs_to
        
        def belongs_to(parent_name)
          set_table_name(parent_name.to_s.pluralize)
          original_belongs_to(parent_name)
        end
      end
      validates_presence_of :parent
    end
  end
end
