local http = require'socket.http'
local url = require 'src.utils.url'
local json = require 'cjson'
local soundcloud = {}

function soundcloud:new()
  local newObj = {
    clientId = nil,
    baseUrl = "https://api-v2.soundcloud.com"
  }
  self.__index = self
  return setmetatable(newObj, self)
end

function soundcloud:init()
  print("[soundcloud]: Setting up clientId for fetch tracks...")
  local mainsite_body = http.request('https://soundcloud.com/')
  if mainsite_body == nil then return self.fetchFailed(self) end

  local assetId = string.gmatch(mainsite_body, "https://a%-v2%.sndcdn%.com/assets/[^%s]+%.js")
  if assetId() == nil then return self.fetchFailed(self) end

  local call_time = 0
  while call_time < 4 do
    assetId()
    call_time = call_time + 1
  end

  local data_body = http.request(assetId())
  if data_body == nil then return self.fetchFailed(self) end

  local matched = data_body:match('client_id=[^%s]+')
  if matched == nil then return self.fetchFailed(self) end
  local clientId = matched:sub(11, 41 - matched:len())
  self.clientId = clientId
  print("[soundcloud]: Setting up clientId for fetch tracks successfully")
end

function soundcloud:fetchFailed()
  print '[soundcloud]: Failed to fetch clientId.'
end

function soundcloud:search(query)
  local query_link =
    self.baseUrl
    .. "/search"
    .. "?q=" .. url:urlencode(query)
    .. "&variant_ids="
    .. "&facet=model"
    .. "&user_id=992000-167630-994991-450103"
    .. "&client_id=" .. self.clientId
    .. "&limit=" .. "20"
    .. "&offset=0"
    .. "&linked_partitioning=1"
    .. "&app_version=1679652891"
    .. "&app_locale=en"

  local res_body = http.request(query_link)
  local decoded = json.decode(res_body)
  local res = {}
  local counter = 1

  for _, value in pairs(decoded.collection) do
    if value.kind ~= "track" then goto continue end
    res[counter] = soundcloud:buildTrack(value)
    counter = counter + 1
    ::continue::
  end

  return res
end

function soundcloud:buildTrack(data)
  return {
    info = {
      title = data.title,
      author = data.user.permalink,
      identifier = data.id,
      uri = data.permalink_url,
      is_stream = false,
      source_name = "soundcloud",
      isrc = data.urn,
      artwork_url = data.artwork_url,
      length = data.full_duration
    }
  }
end

return soundcloud