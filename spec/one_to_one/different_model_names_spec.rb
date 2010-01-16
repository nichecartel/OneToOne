require 'spec_helper'

class CreatePeople < ActiveRecord::Migration
  class << self
    alias_method(:noisy_migrate, :migrate)
    def migrate(*args)
      orig_stdout = $stdout
      $stdout = StringIO.new
      
      super(*args)
      
      $stdout = orig_stdout
    end
  end
  
  def self.up
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.integer :age
      
      t.string :human_genome__sequence
      t.boolean :human_genome__complete
      t.integer :human_genome__intron_count

      t.timestamps
    end
  end
  def self.down
    drop_table :people
  end
end

CreatePeople.migrate(:up)
at_exit { CreatePeople.migrate(:down) }

describe OneToOne do
  before(:each) do
    silence_warnings do
      Person = Class.new(ActiveRecord::Base) do
        include OneToOne
        has_one(:human_genome)
      end
      HumanGenome = Class.new(ActiveRecord::Base) do
        include OneToOne
        belongs_to(:person)
      end
    end
  end

  context 'when the class names are not Parent and Child' do
    it 'should allow new instances to be instantiated' do
      lambda do
        Person.new
        HumanGenome.new
      end.should_not raise_error
    end
    it 'should allow associations to be assigned' do
      lambda do
        p = Person.new
        g = HumanGenome.new
        p.human_genome = g
      end.should_not raise_error
      lambda do
        p = Person.new
        g = HumanGenome.new
        g.person = p
      end.should_not raise_error
    end
    it 'should allow associations to be saved' do
      lambda do
        p = Person.new
        g = HumanGenome.new
        p.human_genome = g
        p.save
      end.should_not raise_error
      lambda do
        p = Person.new
        g = HumanGenome.new
        g.person = p
        g.save
      end.should_not raise_error
    end
    it 'should allow instances to be updated' do
      p = Person.new
      g = HumanGenome.new
      p.human_genome = g
      p.save
      p.update_attributes(:first_name => 'David')
      p.first_name.should == 'David'
      g.sequence = 'GATACA'
      g.save
      g.sequence.should == 'GATACA'
    end
  end
end
