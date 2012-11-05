require "rubygems"
require "redis"

module StructSelector
  module Collections
    class Redis
      attr_accessor :struct_name, :redis
      private :struct_name
      include Enumerable

      def initialize
        @struct_name = self.class.to_s.downcase
        @redis = ::Redis.new
        self
      end

      def add obj
        redis.sadd(struct_name, obj.id)
        redis.set(struct_name + ":" + obj.id.to_s, Marshal.dump(obj))
        self
      end

      def each
        redis.smembers(struct_name).each do |id|
          yield Marshal.load(redis.get(struct_name + ":" + id))
        end
      end

      def [](id)
        return nil unless id_present?(id)
        Marshal.load(redis.get(struct_name + ":" + id.to_s))
      end

      def del obj
        del_by_id obj.id
      end

      def del_by_id id
        return nil unless id_present?(id)
        redis.srem(struct_name, id.to_s)
        redis.get(struct_name + ":" + id.to_s)
      end

      def id_present? id
        redis.sismember(struct_name, id.to_s)
      end
      private :id_present?

    end
  end
end
