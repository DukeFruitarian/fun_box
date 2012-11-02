module StructFinder
  class Base

    def initialize collection
      @collection = collection
      @data = Hash.new{|h,k| h[k] = Hash.new{|h2,k2| h2[k2]=[]}}
      @collection.each do |el|
        @data[:sex][el.sex] << el.id
        @data[:age][el.age] << el.id
        @data[:height][el.height] << el.id
        @data[:index][el.index] << el.id
        @data[:money][el.money.floor] << el.id
=begin
        @money = []
        @money[el.money.floor] = []
        @money[el.money.floor] << el.id


time_hash = Benchmark.realtime do
          1000000.times{@data[:money][el.money.floor]}
        end

        time_arr = Benchmark.realtime do
          1000000.times{@money[el.money.floor]}
        end
        debugger
        ""
=end
      end
    end

    def select params={}
      return nil unless params.kind_of?(Hash)
      return @collection.map if params.empty?
      res = nil
      order = optimize_select_order(params)

      minimal = order.shift
      array_of_min_param = []
      select_hash={}

      if params[minimal].kind_of?(Range)
        params[minimal].each do |num|
          array_of_min_param += @data[minimal][num]
        end
      else
        array_of_min_param = @data[minimal][params[minimal]]
      end

      order.each do |attribute|
        select_hash[attribute] = params[attribute].kind_of?(Range) ?
          params[attribute] : [params[attribute]]
      end

      lmbd = lambda do |el|
        order.each do |attribute|
          return false unless select_hash[attribute].include?(@collection[el].send(attribute))
        end
      end

      array_of_min_param.select(&lmbd).inject([]) do |result,id|
        result << @collection[id]
      end
=begin
      @data[minimal][]
      order.each do |param|
        array_of_one_param = []
        if params[param].kind_of?(Range)
          params[param].each do |num|
            array_of_one_param + @data[param][num]
          end
        else
          array_of_one_param=@data[param][params[param]]
          res = res ? res&array_of_one_param : array_of_one_param
        end
      end
      #debugger
      #""
      res
      #@collection[*ids]
=end
    end

    def optimize_select_order params
      order = {}
      params.each_pair do |attribute,value|
        val = value.kind_of?(Range) ? value.count : 1
        if attribute == :sex
          order[:sex] = 1.0/2
        elsif attribute == :age
          order[:age] = 1.0/100*(val)
        elsif attribute == :height
          order[:height] = 1.0/300*(val)
        elsif attribute == :index
          order[:index] = 1.0/100000*(val)
        elsif attribute == :money
          order[:money] = 1.0/100000*(val+1)
        end
      end
      t = order.sort_by{|h|h.last}.map{|h|h.first}
      #debugger
      #""
    end
    private :optimize_select_order

  end
end
