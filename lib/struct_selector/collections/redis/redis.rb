require "rubygems"
require "redis"

module StructSelector
  module Collections
    # Класс коллекции основанной на Hash DB Redis
    # Требования: установленный гем redis и запущенный сервер на
    #   стандартном порту 6379
    #
    # Для использования необходимо наследоваться от этого класса, например
    #   Persons < StructSelector::Collections::Redis и создать объект коллекции
    #   coll = Persons.new
    class Redis
      attr_reader :struct_name, :redis, :selector, :selector_presense
      private :struct_name, :redis, :selector, :selector_presense
      include Enumerable

      # Инициализация без аргументов или с параметрами сервера Redis
      def initialize params = {}
        # Название для хеша в базе данных берём из имени класса
        @struct_name = self.class.to_s.downcase
        # создаём новый клиент для связи с базой данных
        @redis = ::Redis.new params
        # Переменная присутствия селектора, чтобы не вызывать каждый раз selector,
        #   т.к. это снижает производительность из-за большого количества информации в нём
        @selector_presense = false
        self
      end

      # Установка селектора
      def set_selector selector
        @selector = selector
        @selector_presense = true
      end

      # Добавление элемента в коллекцию
      def add obj
        # Добавление в базу данных
        redis.hset(struct_name, obj.id.to_s, Marshal.dump(obj))
        # Вызов add_obj если установлен селектор
        selector.add_obj(obj) if selector_presense
        # Возвращение объекта коллекции, чтобы имелась возможность создавать
        #   цепочки методов
        self
      end

      # Метод Each, необходимый для модуля Enumerable
      def each
        redis.hvals(struct_name).each do |el|
          yield Marshal.load(el)
        end
      end

      # Метод [], для произволльного доступа к элементам, возвращает nil,
      #   если элемент не существует
      def [](id)
        marshalize_obj = redis.hget struct_name, id.to_s
        Marshal.load(marshalize_obj) if marshalize_obj
      end

      # Метод-мутатор, для удаления из коллекции объекта, возвращает объект или nil
      def del! obj
        del_by_id! obj.id
      end

      # Метод-мутатор для удаления из коллекции по id, возвращает объект или nil
      def del_by_id! id
        deleted = redis.hget struct_name, id.to_s
        redis.hdel struct_name, id.to_s
        selector.del_obj(Marshal.load(deleted)) if deleted && selector_presense
      end

    end
  end
end
