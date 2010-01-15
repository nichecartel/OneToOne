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
          def method_missing(method, *args, &block)
            puts 'method skipped'
          end
        end
      end
      
      Foo.should_receive(:set_table_name).with('parents')
      
      class Foo
        include OneToOne       
        belongs_to(:parent)
      end
      
      Foo.instance_variable_get(:@original_called).should == true
    end
    it 'should use the same table as the Parent class' do
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
      end
      Child.table_name.should == Parent.table_name
    end
    it 'should not raise an error for the Child classes table not found' do
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
      end
      lambda do
        Child.new
      end.should_not raise_error(ActiveRecord::StatementInvalid, "Could not find table 'children'")
    end
    
    it 'should raise an error if a Child instance is saved without an associated Parent instance' do
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
      end
      child = Child.new
      child.valid?
      child.errors.should_not be_empty
      child.errors.on('parent').should =~ /can't be blank/
    end
    it 'should allow the error message to be overridden' do
      pending
    end
    
    it 'should raise an error if another belongs_to association is declared' do
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
        lambda do 
          belongs_to(:a_different_class).should raise_error(NoMethodError, 'Child already has a parent class named Parent') 
        end
      end
    end
  end
  
end
