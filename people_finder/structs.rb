module Fake
  class Person
    attr_accessor :sex, :age, :height, :index, :money, :id
    def self.next_id
      @id||=-1
      @id+=1
    end

    def initialize
      @sex = rand(2)
      @age = rand(100)
      @height = rand(300)
      @index = rand(100000)
      @money = rand*100000
      @id = Person.next_id
    end
  end

  class Car
    attr_accessor :door_count, :engine_volume, :production_year, :weigh, :screw_count, :id
    def self.next_id
      @id||=-1
      @id+=1
    end

    def initialize
      @door_count = 3 + rand(2)
      @engine_volume = 1000 + rand(6000)
      @production_year = 1950 + rand(63)
      @weigh = 2000 + rand*10000
      @screw_count = 1000 + rand(100000)
      @id = Car.next_id
    end
  end
end
