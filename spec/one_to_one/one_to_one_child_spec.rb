require 'spec_helper'

describe OneToOne do
  context 'when included in the Child class' do
    before(:each) do      
      silence_warnings do
        Parent = Class.new(ActiveRecord::Base) do
        end
        Child = Class.new(ActiveRecord::Base) do
        end
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
    
    it "should alias attributes for the child instance which begin with 'child__'" do
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
      end
      child = Child.new
      child.attributes[:child__name].should == nil
      child.attributes = {:name => 'David'}
      child.attributes['child__name'].should == 'David'
    end
    it "should alias attributes for the child instance which begin with 'child__' when the object is created with them" do
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
      end
      child = Child.new({:name => 'David'})
      child.attributes['child__name'].should == 'David'
    end
    
    it 'should display the Child class nicely with the aliased attributes' do
      pending
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
      end
      Child.column_names.should == ['id', 'name']
      Child.inspect.should == 'Child(id: integer, name: string)'
    end
    it 'should display a Child instance nicely with the aliased attributes' do
      pending
      Child.class_eval do
        include OneToOne
        belongs_to(:parent)
      end
      c = Child.new
      c.inspect.should == '#<Child id: nil, name: nil>'
    end
    
    context 'and a child instance is being created' do
      context 'and the parent has no errors' do
        before(:each) do
          CreateParents.migrate(:down)
          CreateParents.migrate(:up)
        end
        it 'should not validate a Child instance without an associated Parent instance' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.valid?
          child.errors.should_not be_empty
          child.errors.on('parent').grep(/can't be blank/).should_not be_empty
        end
        it 'should validate a Child instance with an associated Parent instance' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child.should be_valid
        end
        it 'should save the child in the parents table if Child#save is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child.save
          Child.find(1).should == child
        end
        
        it "should save the child's attributes in the parents table if Child#save is called" do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new(:child__name => 'David')
          child.parent = Parent.new
          child.save
          Child.find(1).name.should == 'David'
        end
        it "should allow the child's attributes to be assigned using AR dynamic attributes" do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.name = 'David'
          child.parent = Parent.new
          child.save
          Child.find(1).name.should == 'David'
        end
        
        it 'should save the child in the parents table if Child#save! is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child.save!
          Child.find(1).should == child
        end
        it 'should save the child in the parents table if Child#create is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.create(:parent => Parent.new)
          Child.find(1).should == child
        end
        it 'should save the child in the parents table if Child#create! is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child = Child.create!(:parent => Parent.new)
          Child.find(1).should == child
        end
      end
      
      context 'and the parent has errors' do
        before(:each) do
          CreateParents.migrate(:down)
          CreateParents.migrate(:up)
          Parent.class_eval do
            validates_acceptance_of :must_be_true, :accept => true
          end
        end
        it 'should not save the child if Child#save is called and the parent has errors' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new(:must_be_true => false)
          child.save
          child.should be_new_record
          child.errors.should_not be_empty
          child.errors.on('parent').grep(/has errors/).should_not be_empty
        end
        it 'should not save the child if Child#save! is called and the parent has errors' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new(:must_be_true => false)
          child.save!
          child.should be_new_record
          child.errors.should_not be_empty
          child.errors.on('parent').grep(/has errors/).should_not be_empty
        end
        it 'should not save the child if Child#create is called and the parent has errors' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.create(:parent => Parent.new(:must_be_true => false))
          child.should be_new_record
          child.errors.should_not be_empty
          child.errors.on('parent').grep(/has errors/).should_not be_empty
        end
        it 'should not save the child if Child#create! is called and the parent has errors' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.create!(:parent => Parent.new(:must_be_true => false))
          child.should be_new_record
          child.errors.should_not be_empty
          child.errors.on('parent').grep(/has errors/).should_not be_empty
        end
      end
    end
    
    
    context 'and a child instance is being updated' do
      context 'and the parent has no errors' do
        before(:each) do
          CreateParents.migrate(:down)
          CreateParents.migrate(:up)
        end
        it 'should not validate a Child instance without an associated Parent instance' do          
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child.save
          
          child.parent = nil
          child.valid?
          child.errors.should_not be_empty
          child.errors.on('parent').grep(/can't be blank/).should_not be_empty
        end
        it 'should not validate a Child instance with a newly associated Parent instance' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child.save
          
          child.parent = Parent.new
          child.valid?
          child.errors.should_not be_empty
          child.errors.on('parent').grep(/cannot be changed to another/).should_not be_empty
        end
        it 'should save the child in the parents table if Child#save is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child.save
          child.name = 'David'
          child.save
          Child.find(1).name.should == 'David'
        end
        it 'should save the child in the parents table if Child#save! is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          child.parent = Parent.new
          child.save
          child.name = 'David'
          child.save!
          Child.find(1).name.should == 'David'
        end
        it 'should save the child in the parents table if Child#update_attributes is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.create(:parent => Parent.new)
          child.update_attributes({:name => 'David'})
          Child.find(1).name.should == 'David'
        end
        it 'should save the child in the parents table if Child#update_attributes! is called' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.create(:parent => Parent.new)
          child.update_attributes!({:name => 'David'})
          Child.find(1).name.should == 'David'
        end
        it 'should save the child in the parents table if Child.update is called' do
          pending
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.create(:parent => Parent.new)
          Child.update(child.id, :name => 'David')
          Child.find(1).name.should == 'David'
        end
        it 'should not allow the parent attributes to be updated' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.create(:parent => Parent.new)
          lambda do
            child.update_attributes({:parent_name => 'David'})
          end.should raise_error(ActiveRecord::UnknownAttributeError)
        end
      end
      
      context 'and the parent has errors' do
        before(:each) do
          CreateParents.migrate(:down)
          CreateParents.migrate(:up)
          Parent.class_eval do
            validates_acceptance_of :must_be_true, :accept => true
          end
        end
        it 'should save the child but not the parent if Child#save is called and the parent has errors' do
          Child.class_eval do
            include OneToOne
            belongs_to(:parent)
          end
          child = Child.new
          parent = child.parent = Parent.new
          child.save
          child.should_not be_new_record
          
          parent.must_be_true = false
          
          child.name = 'David'
          child.should be_valid    
          child.save
          Child.first(1).name.should == 'David'
          Parent.first(1).must_be_true.should == true      
        end
      end      
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
