require "benchmark"
require "rubygems"
require "redis"
require File.join(File.dirname(__FILE__), "../struct_selector")
require File.join(File.dirname(__FILE__), "structs")

class Persons < StructSelector::Collections::Redis
end

Benchmark.bm do |b|
  b.report("redis filler") do
    collection = Persons.new
    10.times do
      Thread.new do
        10000.times do
          collection.add Fake::Person.new
        end
      end
    Thread.list.each{|th| th.join unless Thread.current == th}
    end
  end
end
