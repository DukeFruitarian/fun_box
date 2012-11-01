module SpaceFinder
  class Base
    def initialize array
      # массив результатов
      @res = []

      # в переменные экземпляра записывается массив, размер массива,
      # первый элемент, количество пропусков
      @array,@first,size = array, array.first, array.size
      @space_count = array.last-@first-size+1
    end

    def spaces
      find_root(@first,@array,@space_count)
      @res
    end

    def find_root(first,array,space_count)

    end
    private :find_root

  end
end
