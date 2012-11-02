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
