module StructSelector
  # Класс StructFinder::Base. Производит выборку из коллекции,
  #   по произвольным аттрибутам.
  # Колелкция должна отвечать требованиям:
  #  - включать в себя модуль Enumerable
  #  - отдавать элемент по методу [el_id] c id == el_id
  #
  # Предполагал реализовать ещё классы коллекций для различных баз данных:
  #   StructFinder::Collections::MySQL, StructFinder::Collections::PG и особенно
  #   высокоэффективный StructFinder::Collections::Redis(которые наследовались бы от
  #   StructFinder::Collections:AbstractCollection), но подумал что и так
  #   выбился за рамки изначального задания. Однако, если Вы будете заинтересованны
  #   в реализации этих классов (например, если нужно будет что-то дополнительно сделать
  #   для определения моей квалификации) с удовольствием реализую.
  #
  # Элементы коллекции должны:
  #  - отвечать на метод id
  #  - иметь attr_reader на заявленные в инициализации StructFinder::Base аттрибуты

  # Примечание: эффективность реализации повышается при
  #   конкретизировании одного запроса, снижается при  усреднении вероятности
  #   попадания для каждого аттрибута, практически не меняется от количества
  #   аттрибутов в селекции

  class Base
    # Инициализация. Пример использования:
    # finder = StructFinder::Base.new persons_array,
    #   :sex=>0..1,
    #   :age => 0..100,
    #   :height => 0..300,
    #   :index => 0..10000,
    #   :money => {:range =>(0..10000), :type => float }
    def initialize collection, attributes
      @collection = collection

      collection.set_selector self unless collection.kind_of?(Array)

      # Хеш для хранения данных, где ключом является аттрибут,
      # а значением - ещё один хеш. Во внутреннем хеше ключом является
      # значение аттрибута, а значением - id элемента коллекции.
      @data = Hash.new{|h,k| h[k] = Hash.new{|h2,k2| h2[k2]=[]}}

      # Хеш для кеширования
      @cache = {}

      # Хеш для хранения границ аттрибутов. Например @border_hash[:sex] == 0..1
      @border_hash = {}

      # Тип аттрибута, сейчас поддерживается только Integer и Float,
      #   но легко расширяется для других типов
      @attr_type = {}

      @collection.each do |el|
        attributes.each_pair do |attribute,value|
          # Если значение параметра не хеш - значит Range, и тип Integer по умолчанию
          unless value.kind_of?(Hash)
            @border_hash[attribute] = value
            @attr_type[attribute] = Integer
          # В противном случае это хеш с ключами :range и :type
          else
            @border_hash[attribute] = value[:range]
            @attr_type[attribute] = value[:type]
          end

          # Если тип текущего аттрибута Float, округляем для поиска до нижней границы
          value = @attr_type[attribute].equal?(Float) ?
            el.send(attribute).floor : el.send(attribute)

          # Добавляем элемент в хеш @data для каждого заявленного в параметрах аттрибута
          @data[attribute][value] << el.id
        end
      end
    end


    # Интерфейс для использования поиска. Пример использования:
    #   finder.select :age => 15, :sex => 1, :money => 0..200
    def select params={}
      # возвращаем nil если параметр не типа Hash
      return nil unless params.kind_of?(Hash)

      # Возвращаем полную коллекцию, если параметр не задан или == {}
      return @collection.map if params.empty?

      # Возвращаем кеш если уже был данный запрос
      return @cache[params] if @cache[params]

      res = nil
      order = optimize_select_order(params)

      # Выделяем аттрибут, вероятно, с наименьшим количеством совпавших условий
      minimal = order.shift

      # Массив, содержащий коллекцию id для "минимального" аттрибута
      array_of_min_param = []

      # Если "минимальный" параметр в своём условии содержит интервал,
      # В массив добавляем все id, аттрибут которых лежит в этом интервале
      if params[minimal].kind_of?(Range)
        params[minimal] = params[minimal].to_a.push(params[minimal].last + 1) if @attr_type[minimal].equal?(Float)
        params[minimal].each do |num|
          array_of_min_param += @data[minimal][num]
        end
      # В проивном случае массив представляет собой коллекцию id,
      # соответствующих уловию @collection[id].send(:minimal) == params[minimal]
      else
        array_of_min_param = @data[minimal][params[minimal]]
      end

      # Формируем хеш для отбора элементов из array_of_min_param
      select_hash={}

      order.each do |attribute|
        # Для единого API в поиске, если условие отбора число - формируем
        # массив с единственным элементом
        select_hash[attribute] = params[attribute].kind_of?(Range) ?
          params[attribute] : [params[attribute]]
      end

      # Формирование lambda-функции, для того чтобы return
      # не возвращал из StructFinder::Base#select
      lmbd = lambda do |el|
        # Аттрибуты отсортированы по вероятному количеству элементов
        order.each do |attribute|
          return false unless select_hash[attribute].include?(@collection[el].send(attribute))
        end
      end

      # Непосредственная выборка, с последующим возвратом элементов базовой коллекции
      @cache[params] = array_of_min_param.select(&lmbd).inject([]) do |result,id|
        result << @collection[id]
      end
    end

    def add_obj obj
      @attr_type.each_pair do |attribute, type|
        value = type.equal?(Float) ? obj.send(attribute).floor : obj.send(attribute)
        @data[attribute][value] << obj.id
      end
    end

    def del_obj obj
      @attr_type.each_pair do |attribute, type|
        value = type.equal?(Float) ? obj.send(attribute).floor : obj.send(attribute)
        @data[attribute][value].delete(obj.id)
      end
      obj
    end

    # private метод хелпер, для оптимизации процесса выборки
    def optimize_select_order params
      order = {}
      params.each_pair do |attribute,value|

        # Если значенме параметра является интервал - считаем его длину
        # Если это число - длина равна 1
        length = value.kind_of?(Range) ? value.count : 1

        # Вычисляем среднюю вероятность попадания одного элемента коллекции,
        # в селекцию конкретного аттрибута. Считаем обратную величину размера
        # разброса значений для аттрибута и умножаем на длину интервала выборки
        order[attribute] = 1.0 / @border_hash[attribute].count * length
      end

      # сортируем по вероятности и выбираем только символы аттрибутов
      order.sort_by{|h| h.last}.map{|h|h.first}
    end
    private :optimize_select_order

  end
end
