require "benchmark"
time_times = Benchmark.realtime do
  1000001.times do
    [1,2,3,4,5,6,7,8,9].each do |num|
      if num > 100
      end
    end
  end
end

time_upto = Benchmark.realtime do
  0.upto(1000000) do
    [1,2,3,4,5,6,7,8,9].each do |num|
      if num > 100
      end
    end
  end
end

time_for = Benchmark.realtime do
  for i in(0..1000000) do
    [1,2,3,4,5,6,7,8,9].each do |num|
      if num > 100
      end
    end
  end
end

time_loop = Benchmark.realtime do
  i=0
  loop do
  i+=1
    [1,2,3,4,5,6,7,8,9].each do |num|
      if num > 100
      end
    end
  break if i==1000001
  end
end

time_while = Benchmark.realtime do
  i=0
  while i<1000001 do
    i+=1
    [1,2,3,4,5,6,7,8,9].each do |num|
      if num > 100
      end
    end
  end
end

time_each = Benchmark.realtime do
  i=0
  (0..1000001).each do
    [1,2,3,4,5,6,7,8,9].each do |num|
      if num > 100
      end
    end
  end
end

p time_times
p time_upto
p time_for
p time_loop
p time_while
p time_each
