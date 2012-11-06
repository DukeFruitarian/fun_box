require "rubygems"
require "redis"
require "debugger"

module StructSelector
  module Collections
    class Redis
      attr_reader :struct_name, :redis, :selector, :selector_presense
      private :struct_name, :redis, :selector, :selector_presense
      include Enumerable

      def initialize
        @struct_name = self.class.to_s.downcase
        @redis = ::Redis.new
        @selector_presense = false
        self
      end

      def set_selector selector
        @selector = selector
        @selector_presense = true
      end

      def add obj
        redis.hset(struct_name, obj.id.to_s, Marshal.dump(obj))
        selector.add_obj(obj) if selector_presense
        self
      end

      def each
        redis.hvals(struct_name).each do |el|
          yield Marshal.load(el)
        end
      end

      def [](id)
        marshalize_obj = redis.hget struct_name, id.to_s
        Marshal.load(marshalize_obj) if marshalize_obj
      end

      def del obj
        del_by_id obj.id
      end

      def del_by_id id
        deleted = redis.hget struct_name, id.to_s
        redis.hdel struct_name, id.to_s
        selector.del_obj(Marshal.load(deleted)) if deleted && selector_presense
      end

    end
  end
end
