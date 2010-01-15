$LOAD_PATH << File.join(File.dirname(__FILE__),"..","lib")

require 'activerecord'
require 'spec'
require 'one_to_one'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3' ,
  :database => File.join(File.dirname(__FILE__),'one_to_one.sqlite3')
)

class CreateParents < ActiveRecord::Migration
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
    create_table :parents do |t|     
      t.boolean :child__must_be_true, :default => true, :nil => true
      t.boolean :must_be_true, :default => true, :nil => true
      t.string :child__name
      t.string :parent_name
    end
  end
  def self.down
    drop_table :parents
  end
end

CreateParents.migrate(:up)
at_exit { CreateParents.migrate(:down) }
