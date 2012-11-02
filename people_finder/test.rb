# непосредственно модуль поиска
require File.join(File.dirname(__FILE__), "struct_finder/struct_finder")

# структуры-хелперы
require File.join(File.dirname(__FILE__), "structs")
require "debugger"
require "benchmark"


# основное время занимает создание 10 миллионов фейковых записей
# пример из задания
persons = (0..999999).map{Fake::Person.new}
persons_finder = StructFinder::Base.new(persons,
  :sex => 0..1,
  :age => 0..100,
  :height => 0..300,
  :index => 0..100000,
  :money => {:range => 0..100000, :type => Float }
 )

# приммер с поиском машин
cars = (0..999999).map{Fake::Car.new}
cars_finder = StructFinder::Base.new(cars,
  :door_count => 3..5,
  :engine_volume => 1000..6999,
  :production_year => 1950..2012,
  :weigh => {:range => 2000..11999, :type => Float },
  :screw_count => 1000..100999
 )


per=nil
time_per = Benchmark.realtime do
  1.times do
  per = persons_finder.select :age => 40..100,
    :sex => 0,
    :height => 180,
    :index => 0..500,
    :money => 2000..25000
  end
end

cr = nil
time_car = Benchmark.realtime do
  1.times do
  cr = cars_finder.select :door_count => 4,
    :production_year => 2000..2012,
    :weigh => 7000..8000,
    :screw_count => 50000..50100
  end
end

st=nil
time_standart = Benchmark.realtime do
  1.times do
   st = persons.select{ |el| el.sex == 0 && el.age <=100 && el.age >= 40  && el.height == 180 && el.index >= 0 && el.index <=500}
  end
end

debugger
""
