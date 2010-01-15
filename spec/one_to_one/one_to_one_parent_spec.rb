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
    
    end
  
  end
end
