# непосредственно модуль поиска
require File.join(File.dirname(__FILE__), "struct_finder/struct_finder")

# структуры-хелперы
require File.join(File.dirname(__FILE__), "structs")
require "debugger"
require "benchmark"

array = (0..999999).map{Person.new}
sf = StructFinder::Base.new(array)

my=nil
time_my = Benchmark.realtime do
  3.times do
  my = sf.select :age => 40..100, :sex => 0, :height => 180, :index => 0..500
  end
end

st=nil
time_standart = Benchmark.realtime do
  3.times do
   st = array.select{ |el| el.sex == 0 && el.age <=100 && el.age >= 40  && el.height == 180 && el.index >= 0 && el.index <=500}
  end
end

debugger
""
