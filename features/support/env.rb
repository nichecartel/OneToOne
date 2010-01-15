$LOAD_PATH << File.join(File.dirname(__FILE__),"..","..","lib")

require 'activerecord'
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3' ,
  :database => 'one_to_one.sqlite3'
)

class CreateParents < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
     
    end
  end
  def self.down
    drop_table :parents
  end
end

CreateParents.migrate(:down)
