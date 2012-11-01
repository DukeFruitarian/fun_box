module SpaceFinder
  class Base
      attr_accessor :res, :step
      private :res, :step
    def initialize array, arr_step
      # массив результатов
      @res = []

      # в переменные экземпляра записывается массив, размер массива,
      # первый элемент, количество пропусков, шаг в массиве
      @array,@first,size = array, array.first, array.size
      @space_count = array.last-@first-size+1
      self.step = arr_step
    end

    # интерфейс использования класса
    def spaces
      find_root(@first,@array,@space_count)
      res.sort!
    end

    # рекурсивная функция поиска пропущенного элемента.
    # аргументы - первый элемент массива
    def find_root(first,array,space_count)
      return if space_count == 0
      size = array.size
      middle_idx = size.even? ? size/2-1 : size/2

      unless middle_idx == array.size - 1
        top_delta = array[middle_idx+1]-array[middle_idx]-1
        top_array = array[middle_idx+1..size-1]
        top_spaces = array.last - array[middle_idx+1] - top_array.size + 1
        unless top_delta == 0
          top_delta.times do |space|
            res << array[middle_idx] + space
          end
        end
        find_root(array[middle_idx+1],top_array,top_spaces)
      end

      unless middle_idx == 0
        bot_delta = array[middle_idx]-array[middle_idx-1] - 1
        bot_array = array[0..middle_idx-1]
        bot_spaces = array[middle_idx-1] - array.first - bot_array.size + 1
        unless bot_delta == 0
          bot_delta.times do |space|
            res << array[middle_idx] - space
          end
        end
        find_root(array.first,bot_array,bot_spaces)
      end
    end
    private :find_root

  end
end
