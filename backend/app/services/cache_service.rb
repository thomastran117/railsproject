require "securerandom"
require "json"

class CacheService < BaseCacheService
  def set_value(key, value, expiry: nil)
    execute(false) do
      if expiry
        redis.set(ns(key), value.to_s, ex: expiry.to_i)
      else
        redis.set(ns(key), value.to_s)
      end
      true
    end
  end

  def get_value(key)
    execute(nil) { redis.get(ns(key)) }
  end

  def delete_key(key)
    execute(false) { redis.del(ns(key)) > 0 }
  end

  def key_exists?(key)
    execute(false) { redis.exists?(ns(key)) == 1 }
  end

  def increment(key, value: 1)
    execute(0) { redis.incrby(ns(key), value.to_i) }
  end

  def decrement(key, value: 1)
    execute(0) { redis.decrby(ns(key), value.to_i) }
  end

  def hash_set(key, field, value)
    execute(false) do
      redis.hset(ns(key), field.to_s, value.to_s)
      true
    end
  end

  def hash_get(key, field)
    execute(nil) { redis.hget(ns(key), field.to_s) }
  end

  def hash_get_all(key)
    execute({}) { redis.hgetall(ns(key)) }
  end

  def hash_delete(key, field)
    execute(false) { redis.hdel(ns(key), field.to_s) > 0 }
  end

  def set_add(key, value)
    execute(false) { redis.sadd(ns(key), value.to_s) > 0 }
  end

  def set_remove(key, value)
    execute(false) { redis.srem(ns(key), value.to_s) > 0 }
  end

  def set_members(key)
    execute([]) { redis.smembers(ns(key)) }
  end

  def list_left_push(key, value)
    execute(0) { redis.lpush(ns(key), value.to_s) }
  end

  def list_right_push(key, value)
    execute(0) { redis.rpush(ns(key), value.to_s) }
  end

  def list_left_pop(key)
    execute(nil) { redis.lpop(ns(key)) }
  end

  def list_right_pop(key)
    execute(nil) { redis.rpop(ns(key)) }
  end

  def get_ttl(key)
    execute(nil) do
      ttl = redis.ttl(ns(key))
      return nil if ttl.nil? || ttl < 0
      ttl
    end
  end

  def set_expiry(key, expiry)
    execute(false) { redis.expire(ns(key), expiry.to_i) }
  end

  def acquire_lock(key, expiry:)
    token = SecureRandom.uuid
    ok = execute(false) do
      redis.set(ns(key), token, nx: true, ex: expiry.to_i)
    end
    ok ? token : nil
  end

  def release_lock(key, token)
    script = <<~LUA
      if redis.call("GET", KEYS[1]) == ARGV[1] then
        return redis.call("DEL", KEYS[1])
      else
        return 0
      end
    LUA

    execute(false) do
      redis.eval(script, keys: [ns(key)], argv: [token]) == 1
    end
  end

  def scan_keys(pattern, count: 500)
    execute([]) do
      cursor = "0"
      out = []
      loop do
        cursor, keys = redis.scan(cursor, match: ns(pattern), count: count)
        out.concat(keys)
        break if cursor == "0"
      end
      out
    end
  end

  def get_many(keys)
    execute({}) do
      arr = keys.map { |k| ns(k) }
      return {} if arr.empty?

      values = redis.mget(*arr)
      result = {}

      arr.each_with_index do |full_key, i|
        result[full_key] = values[i]
      end

      result
    end
  end

  def set_json(key, obj, expiry: nil)
    set_value(key, JSON.generate(obj), expiry: expiry)
  end

  def get_json(key)
    raw = get_value(key)
    return nil if raw.nil?
    JSON.parse(raw)
  rescue JSON::ParserError
    nil
  end
end
