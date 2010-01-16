Have you ever struggled with whether to create a 1 to 1 relationship between two model classes or just lump all the attributes into one model? 

Consider an example: People and Genomes. Each Person has their own unique Genome, which no one else shares (even identical twins have base pair mutations relative to one another). So you could put all the data in the People table. Yet it feels wierd to lump methods like 'contains_dna_repeat_sequence?(x)' in with the Person class.

In database land, 1 to 1 relationship are suspect. They indicate the potential for normalizing the data by combining the columns into one table, and thus avoiding frequent joins.
In object oriented land, 1 to 1 relationship are a natural way to separate concerns.

This plugin gives you the best of both worlds. It allows you to add the attributes of both classes into one database table, and then use the classes like a normal 1 to 1 relationship.

### Usage

    #open up irb while in one_to_one/lib
    require 'rubygems'
    require 'activerecord'
    require 'one_to_one'

    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3' ,
      :database => File.join(File.dirname(__FILE__),'one_to_one.sqlite3')
    )

    class CreatePeople < ActiveRecord::Migration
      def self.up
        create_table :people do |t|
        
        #People attributes
          t.string :first_name
          t.string :last_name
          t.integer :age
          
        #Genome attributes
          t.string :genome__sequence
          t.boolean :genome__complete
          t.integer :genome__intron_count
          
        end
      end
      def self.down
        drop_table :people
      end
    end

    CreatePeople.migrate(:up)
    at_exit { CreatePeople.migrate(:down) }

    class Person < ActiveRecord::Base
      include OneToOne
      has_one :genome
    end
    class Genome < ActiveRecord::Base
      include OneToOne
      belongs_to :person
    end

    p = Person.new(:first_name => 'Stanley', :last_name => 'Drew', :age => 25)
    #=> #<Person id: nil, first_name: "Stanley", last_name: "Drew", age: 25, created_at: nil, updated_at: nil>
    g = Genome.new(:sequence => 'GATACA', :complete => true, :intron_count => 200)
    #=> #<Genome id: nil, genome__sequence: "GATACA", genome__complete: true, genome__intron_count: 200>
    p.genome = g
    #=> #<Genome id: nil, genome__sequence: "GATACA", genome__complete: false, genome__intron_count: 200>
    g.save
    #=> true
    p
    #=> #<Person id: 1, first_name: "Stanley", last_name: "Drew", age: 25>
    g
    #=> #<Genome id: 1, genome__sequence: "GATACA", genome__complete: false, genome__intron_count: 200>
    g.complete = false
    #=> false
    g.intron_count
    #=> 200

    #Look Ma, No JOIN
    Genome.find(:first, :conditions => ["first_name = ? AND age > ? AND genome__intron_count = ? ", 'Stanley', 20, 200])
    #=> #<Genome id: 1, genome__sequence: "GATACA", genome__complete: false, genome__intron_count: 200>


### Note
Dynamic finders (find_by_*) do not use the shortened attribute names, although they still work for the actual column names.
This plugin also does not yet attempt to minimize database roundtrips when accessing related objects.
