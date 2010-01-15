require 'spec_helper'

describe OneToOne do
  context 'when included in the Child class' do
    before(:all) do
      CreateParents.migrate(:up)
      at_exit { CreateParents.migrate(:down) }    
    end
    before(:each) do
      Parent = Class.new(ActiveRecord::Base) do
      end
      Child = Class.new(ActiveRecord::Base) do
        include OneToOne
      end
    end
    
    it 'should rename the expected child table when belongs_to is called' do
      class Foo
        class << self
          def belongs_to(parent_class)
            @original_called = true
          end
          def set_table_name(table_name)
          end
        end
      end
      Foo.should_receive(:set_table_name).with('parents')
      Foo.class_eval do
        belongs_to :parent
      end
      Foo.instance_variable_get(:@original_called).should == true
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
