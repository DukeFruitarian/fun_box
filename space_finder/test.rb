require "debugger"
require "benchmark"
require File.join(File.dirname(__FILE__), "spacer/spacer")


# количество элементов в массиве
number_of_element = 100000

# максимальное количество пропущенных элементов
number_of_spaces = 10

array = number_of_element.times.map{|el| el+1}
number_of_spaces.times do |num|
  array.delete((rand*number_of_element).to_int)
end


time_my = Benchmark.realtime do
  100.times do
    finder = SpaceFinder::Base.new(array,1)
    finder.spaces
  end
end

time_standart = Benchmark.realtime do
  100.times do
    finder = []
    array.each_with_index do |el,index|
      if array[index+1] && array[index+1]-el > 1
        (array[index+1]-el).times do |num|
          finder << el+1+num
        end
      end
    end
  end
end


puts "time_my = #{time_my}", "time_standart = #{time_standart}"
