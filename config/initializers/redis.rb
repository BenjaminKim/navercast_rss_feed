require 'connection_pool'
REDIS_POOL = ConnectionPool.new(size: 10) { Redis.new(Rails.configuration.x.redis_spec) }