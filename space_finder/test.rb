require "debugger"
require "benchmark"
require File.join(File.dirname(__FILE__), "spacer/spacer")


# количество элементов в массиве
number_of_element = 1000

# максимальное количество пропущенных элементов
number_of_spaces = 10

array = number_of_element.times.map{|el| el+1}
number_of_spaces.times do |num|
  array.delete((rand*number_of_element).to_int)
end


10000.times do
  finder = SpaceFinder::Base.new(array,1)
end

finder = SpaceFinder::Base.new(array,1)
p finder.spaces
