require 'spec_helper'

describe OneToOne do
  context 'when included in the Child class' do
    before(:all) do
      CreateParents.migrate(:up)
      at_exit { CreateParents.migrate(:down) }
      Parent = Class.new(ActiveRecord::Base) do
        has_one :child
      end
      Child = Class.new(ActiveRecord::Base) do
        include OneToOne
        belongs_to :parent
      end
    end
    it 'should use the same table as the Parent class' do
      Child.table_name.should == Parent.table_name
    end
    it 'should not raise an error for the Child classes table not found' do
      lambda do
        Child.new
      end.should_not raise_error(ActiveRecord::StatementInvalid, "Could not find table 'children'")
    end
  end
  
end
