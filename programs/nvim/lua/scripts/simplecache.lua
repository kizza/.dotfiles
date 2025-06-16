local SimpleCache = {}
local caches = {}

function SimpleCache.new(name, opts)
  opts = opts or {}
  local cache = setmetatable({
    name = name,
    max_size = opts.max_size or 100
  }, { __index = SimpleCache })

  if not caches[name] then -- allow same name to reuse existing
    caches[name] = {
      items = {},
      stats = { hits = 0, misses = 0 }
    }
  end

  return cache
end

---@param key string
---@return table|string|nil
function SimpleCache:get(key)
  local cache = caches[self.name]
  local entry = cache.items[key]

  if entry then
    entry.last_used = vim.loop.now()
    cache.stats.hits = cache.stats.hits + 1
    return entry.value
  end

  cache.stats.misses = cache.stats.misses + 1
  return nil
end

---@param key string
---@param value table|string|nil
function SimpleCache:set(key, value)
  local cache = caches[self.name]

  -- Evict oldest if full
  if #cache.items >= self.max_size then
    local oldest_time = math.huge
    local oldest_key = nil

    for k, entry in pairs(cache.items) do
      if entry.last_used < oldest_time then
        oldest_time = entry.last_used
        oldest_key = k
      end
    end

    if oldest_key then
      cache.items[oldest_key] = nil
    end
  end

  -- Add new entry
  cache.items[key] = {
    value = value,
    last_used = vim.loop.now()
  }
end

function SimpleCache:clear()
  local cache = caches[self.name]
  cache.items = {}
end

function SimpleCache:stats()
  return caches[self.name].stats
end

function SimpleCache:items()
  return caches[self.name]
end

return SimpleCache
