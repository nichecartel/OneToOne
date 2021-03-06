$LOAD_PATH << File.join(File.dirname(__FILE__),"..","..","lib")

require 'activerecord'
require 'one_to_one'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3' ,
  :database => File.join(File.dirname(__FILE__),'one_to_one.sqlite3')
)

class CreateParents < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
      t.boolean :must_be_true, :default => true, :nil => true
      t.string :child__name
    end
  end
  def self.down
    drop_table :parents
  end
end

