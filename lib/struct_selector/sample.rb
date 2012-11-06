# Непосредственно модуль поиска
require File.join(File.dirname(__FILE__), "../struct_selector")

# Структуры-хелперы
require File.join(File.dirname(__FILE__), "structs")
require "benchmark"


# Основное время занимает создание 10 миллионов фейковых записей
# Пример из задания
persons = (0..999999).map{Fake::Person.new}
persons_finder = StructSelector::Base.new(persons,
  :sex => 0..1,
  :age => 0..100,
  :height => 0..300,
  :index => 0..100000,
  :money => {:range => 0..100000, :type => Float }
 )

# Пример с поиском машин
cars = (0..999999).map{Fake::Car.new}
cars_finder = StructSelector::Base.new(cars,
  :door_count => 3..5,
  :engine_volume => 1000..6999,
  :production_year => 1950..2012,
  :weigh => {:range => 2000..11999, :type => Float },
  :screw_count => 1000..100999
)

class Persons < StructSelector::Collections::Redis
end

coll = Persons.new
redis_coll_finder = StructSelector::Base.new(coll,
  :sex => 0..1,
  :age => 0..100,
  :height => 0..300,
  :index => 0..100000,
  :money => {:range => 0..100000, :type => Float }
 )

Benchmark.bm do |b|

  b.report("persons selector") do
    persons_finder.select :age => 40..100,
      :sex => 0,
      :height => 180,
      :index => 0..500,
      :money => 2000..25000
  end

  b.report("cars selector") do
    cars_finder.select :door_count => 4,
      :production_year => 2000..2012,
      :weigh => 7000..8000,
      :screw_count => 50000..50100
  end

  b.report("standart selector") do
    persons.select do |el|
      el.sex == 0 &&
      el.age <=100 &&
      el.age >= 40  &&
      el.height == 180 &&
      el.index >= 0 &&
      el.index <=500
    end
  end

  b.report("redis collection select") do
    redis_coll_finder.select :age => 40..100,
      :sex => 0,
      :height => 180,
      :index => 0..500,
      :money => 2000..25000
  end
end
