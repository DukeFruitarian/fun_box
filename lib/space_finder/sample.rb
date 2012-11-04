require File.join(File.dirname(__FILE__), "base/base")

require "benchmark"

# количество элементов в массиве
number_of_element = 100000

# максимальное количество пропущенных элементов
number_of_spaces = 10

array = number_of_element.times.map{|el| el+1}
number_of_spaces.times do |num|
  array.delete(rand(number_of_element))
end

finder_stand = []
Benchmark.bm do |b|
# 100 поисков SpaceFinder::Base#spaces
  b.report("SpaceFinder") do
    100.times do
      finder = SpaceFinder::Base.new(array)
      finder.spaces
    end
  end

# 100 поисков стандартным перебором
  b.report("Standart") do
    100.times do
      finder_stand.clear
      array.each_with_index do |el,index|
        if array[index+1] && array[index+1]-array[index] > 1
          (array[index+1]-array[index]-1).times do |num|
            finder_stand << array[index]+num+1
          end
        end
      end
    end
  end
end

# вывод результатов
puts "search result:"
print "standart =    "
p finder_stand
finder = SpaceFinder::Base.new(array)
print "SpaceFinder = "
p finder.spaces
