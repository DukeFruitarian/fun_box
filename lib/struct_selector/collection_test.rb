require File.join(File.dirname(__FILE__), "../struct_selector")
require File.join(File.dirname(__FILE__), "structs")
require "benchmark"
require "debugger"

class Persons < StructSelector::Collections::Redis
end

coll = Persons.new

redis_coll_finder = nil
Benchmark.bm do |b|
  b.report("redis finder #new") do
    redis_coll_finder = StructSelector::Base.new(coll,
      :sex => 0..1,
      :age => 0..100,
      :height => 0..300,
      :index => 0..100000,
      :money => {:range => 0..100000, :type => Float }
     )
  end



  b.report("redis selector") do
    debugger
    coll.del_by_id(50)
    coll.del_by_id(10)
    coll.del_by_id(150)
    redis_coll_finder.select :age => 40..100,
      :sex => 0,
      :height => 180,
      :index => 0..500,
      :money => 2000..25000
  end
end
