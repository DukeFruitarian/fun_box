require File.join(File.dirname(__FILE__), "collections/redis/redis")
require File.join(File.dirname(__FILE__), "structs")
require "debugger"

class Persons < StructSelector::Collections::Redis
end

collection = Persons.new
10.times do
  collection.add(Fake::Person.new)
end

collection.each do |per|
  #p per.money
end

debugger
"asd"
