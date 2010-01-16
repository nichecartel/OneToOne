require 'spec_helper'

describe OneToOne do
  context 'when included in the parent class' do
    before(:each) do      
      silence_warnings do
        Parent = Class.new(ActiveRecord::Base) do
          include OneToOne
          has_one(:child)
        end
        Child = Class.new(ActiveRecord::Base) do
          include OneToOne
          belongs_to(:parent)
        end
      end
    end
    
    it 'should allow an instance of the child class to be associated' do
      parent = Parent.new
      child = parent.child = Child.new
      
      parent.child.should == child
    end
    it 'should not have attributes for the child' do
      parent = Parent.new
      parent.attribute_names.grep(/child__/).should == []
    end
    
    context 'and the parent instance is being created' do
      before(:each) do
        CreateParents.migrate(:down)
        CreateParents.migrate(:up)
      end
    
      it 'should allow a parent to be saved before it\'s child' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save
        Parent.find(1).should == parent
        child.save
        Child.find(1).should == child
      end
      it 'should allow a child to be saved after a parent with it\'s attributes' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save!
        child.name = 'David'
        child.save!
        Parent.find(1).should == parent
        Child.find(1).should == child
      end
      it 'should not create a new parent if the child is saved after the parent' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save!
        child.save!
        Parent.count.should == 1
        Parent.find(1).should == parent
        Child.find(1).should == child
      end
      it 'should have the same attributes before and after saving' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save
        Parent.find(1).attributes.should == parent.attributes
      end    
    end
    
    context 'and the parent instance is being updated' do
      before(:each) do
        CreateParents.migrate(:down)
        CreateParents.migrate(:up)
      end
      
      it 'should allow the parent attributes to be updated individually' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save
        parent.should_not be_new_record
        parent.parent_name = 'Kahn'
        parent.save
        parent.reload
        parent.parent_name.should == 'Kahn'
      end
      it 'should allow the parent attributes to be updated en masse' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save
        parent.should_not be_new_record
        parent.update_attributes(:parent_name => 'Kahn')
        parent.reload
        parent.parent_name.should == 'Kahn'
      end
      it 'should not allow the child attributes to be updated individually' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save
        parent.should_not be_new_record
        parent.child__name = 'David'
        parent.save
        child.should be_new_record
        parent.child.name.should be_nil
      end
      it 'should raise an error if the child attributes are updated individually' do
        pending
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save
        parent.should_not be_new_record
        lambda do
          parent.child__name = 'David'
          parent.save
        end.should raise_error(NoMethodError)
        parent.child.name.should be_nil
      end
      it 'should not allow the child attributes to be updated en masse' do
        parent = Parent.new
        child = parent.child = Child.new
        
        parent.save
        parent.should_not be_new_record
        parent.update_attributes(:child__name => 'David')
        child.should be_new_record
        parent.child.name.should be_nil
      end
      
      it 'should not allow the child to be set after creation' do
        parent = Parent.new
        parent.save
        child = parent.child = Child.new(:name => 'David')
        parent.save
        parent.child.name.should == 'David'
      end
      it 'should not allow the child to be replaced' do
        parent = Parent.new
        child = parent.child = Child.new(:name => 'David')
        child.name.should == 'David'
        
        parent.save!
        child.should be_new_record
        child = parent.child = Child.new(:name => 'Steve')
        parent.save!
        child.save!
        parent.child.name.should == 'Steve'
        parent.id.should == child.id
      end
    end
  
  end
end
