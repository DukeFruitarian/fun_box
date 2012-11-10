# !!!!!!!!!!!!!!!!!!!!
# До того как запускать тесты, необходимо выполнить скрипт заполняющий
#   базу данных, файл /scripts/redis_filler.rb, указав необходимое количество записей для
#   генерации.
# !!!!!!!!!!!!!!!!!!!!

# Непосредственно модуль поиска
require File.join(File.dirname(__FILE__), "../struct_selector")

# Структуры-хелперы
require File.join(File.dirname(__FILE__), "structs")
require "benchmark"

class Persons < StructSelector::Collections::Redis
end

# Cоздание 10 миллионов фейковых записей
Benchmark.bm do |b|
  b.report("persons arr create") do
    $persons = (0..999999).map{Fake::Person.new}
  end

  b.report("cars arr create") do
    $cars = (0..999999).map{Fake::Car.new}
  end

  b.report("redis coll create") do
    $redis_coll = Persons.new
  end
end

# Время на создание классов-селекторов
Benchmark.bm do |b|
  b.report("persons selector create") do
    $persons_selector = StructSelector::Base.new($persons,
      :sex => 0..1,
      :age => 0..100,
      :height => 0..300,
      :index => 0..100000,
      :money => {:range => 0..100000, :type => Float }
    )
  end

  b.report("cars selector create") do
    $cars_selector = StructSelector::Base.new($cars,
      :door_count => 3..5,
      :engine_volume => 1000..6999,
      :production_year => 1950..2012,
      :weigh => {:range => 2000..11999, :type => Float },
      :screw_count => 1000..100999
    )
  end

  b.report("redis selector create") do
    $redis_coll_selector = StructSelector::Base.new($redis_coll,
      :sex => 0..1,
      :age => 0..100,
      :height => 0..300,
      :index => 0..100000,
      :money => {:range => 0..100000, :type => Float }
    )
  end
end

# Время непосредственно поиска
Benchmark.bm do |b|
  # Время поиска структур из задания
  b.report("persons select") do
    $persons_selector.select :age => 40..100,
      :sex => 0,
      :height => 180,
      :index => 0..500,
      :money => 2000..25000
  end

  # Время поиска "машин", как пример использования
  b.report("cars select") do
    $cars_selector.select :door_count => 4,
      :production_year => 2000..2012,
      :weigh => 7000..8000,
      :screw_count => 50000..50100
  end

  # Время поиска структур из задания, перебором
  b.report("standart select") do
    $persons.select do |el|
      el.sex == 0 &&
      el.age <=100 &&
      el.age >= 40  &&
      el.height == 180 &&
      el.index >= 0 &&
      el.index <=500 &&
      el.money >= 2000 &&
      el.money <= 25000
    end
  end

  # Время поиска структур из задания из базы данных Redis
  # Количество элементов в БД будет существенно влиять на
  #   создание объекта селектора, и несущественно на время поиска.
  # Созданный один раз селектор, может быть использован во множестве
  #   разнообразных поисков.
  b.report("redis select") do
    $redis_coll_selector.select :age => 40..100,
      :sex => 0,
      :height => 180,
      :index => 0..500,
      :money => 2000..25000
  end
end
