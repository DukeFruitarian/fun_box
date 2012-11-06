require "rubygems"
require "redis"

module StructSelector
  module Collections
    class Redis
      attr_reader :struct_name, :redis, :selector
      private :struct_name, :redis, :selector
      include Enumerable

      def initialize
        @struct_name = self.class.to_s.downcase
        @redis = ::Redis.new
        self
      end

      def set_selector selector
        @selector = selector
      end

      def add obj
        redis.sadd(struct_name, obj.id)
        redis.hset(struct_name + "_hash", obj.id.to_s, Marshal.dump(obj))
        selector.add_obj(obj) if selector
        self
      end

      def each
        redis.hvals(struct_name + "_hash").each do |el|
          yield Marshal.load(el)
        end
      end

      def [](id)
        return nil unless id_present?(id)
        Marshal.load(redis.hget(struct_name + "_hash", id.to_s))
      end

      def del obj
        del_by_id obj.id
      end

      def del_by_id id
        return nil unless id_present?(id)
        redis.srem(struct_name, id.to_s)
        selector.del_obj(Marshal.load(redis.hget(struct_name + "_hash", id.to_s))) if selector
        redis.hget(struct_name + "_hash", id.to_s)
      end

      def id_present? id
        redis.sismember(struct_name, id.to_s)
      end
      private :id_present?

    end
  end
end
