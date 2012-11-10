require "benchmark"
require "rubygems"
require "redis"
require File.join(File.dirname(__FILE__), "../lib/struct_selector")
require File.join(File.dirname(__FILE__), "../lib/struct_selector/structs")

class Persons < StructSelector::Collections::Redis
end

# На моей машине (очень не быстрой) создание 100000 записей и запись их в БД ~ 27 секунд
Benchmark.bm do |b|
  b.report("redis filler") do
    collection = Persons.new
    100000.times do
      collection.add Fake::Person.new
    end
  end
end
