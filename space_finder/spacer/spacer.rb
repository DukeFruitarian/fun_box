module SpaceFinder
  # Класс SpaceFinder производит поиск пропущенных элементов в
  #   массиве последовательных элементов
  #
  # Примечание: эффективность практически не падает при увеличении количества
  #   элементов в массиве, и значительно падает при увеличении пропущенных элементов.
  class Base
      attr_accessor :res
      private :res

    def initialize array
      # массив результатов поиска
      @res = []

      # в переменную экземпляра записывается массив для проверки
      @array = array
    end

    # интерфейс использования класса
    def spaces
      # кеширование результата
      return res unless res.empty?
      find_root(@array)
      res.empty? ? nil : res.sort!
    end

    # рекурсивная функция поиска пропущенного элемента.
    # аргумент - массив элементов
    def find_root(array)
      size = array.size
      first = array.first
      space_count = array.last - first - size + 1

      # возврат если нет пропусков в массиве
      return if space_count == 0

      # вычисление центрального индекса
      middle_idx = size.even? ? size/2-1 : size/2

      # если центральный элемент не является последним,
      #  идёт поиск по массиву выше центрального индекса
      unless middle_idx == array.size - 1
        top_delta = array[middle_idx+1]-array[middle_idx]-1
        top_array = array[middle_idx+1..size-1]
        # если разница между последующим и центральным минус шаг
        # (в данном случае 1, это на будущее,
        # если нужно будет принимать массив с отличным от 1 шагом) не равна 0,
        # то это и есть искомые элементы
        unless top_delta == 0
          top_delta.times do |space|
            res << array[middle_idx] + space + 1
          end
        end
        # продолжение поиска по "верхней" ветке
        find_root(top_array)
      end

      # если центральный элемент не является первым,
      #  идёт поиск по массиву ниже центрального индекса
      unless middle_idx == 0
        bot_delta = array[middle_idx]-array[middle_idx-1] - 1
        bot_array = array[0..middle_idx-1]
        # если разница между центральным и предыдущим минус шаг
        # не равна 0, то это и есть искомые элементы
        unless bot_delta == 0
          bot_delta.times do |space|
            res << array[middle_idx] - space - 1
          end
        end
        # продолжение поиска по "нижней" ветке
        find_root(bot_array)
      end
    end
    private :find_root

  end
end
