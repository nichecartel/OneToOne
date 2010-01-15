module OneToOne
  module ClassMethods
    alias_method(:original_belongs_to, :belongs_to)
    def belongs_to(parent_name)
      self.set_table_name(parent_name.to_s.pluralize)
      self.original_belongs_to
    end
  end
end
