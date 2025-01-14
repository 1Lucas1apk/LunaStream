local json = require("json")

return function (req, res, answer, luna)
  local getEncode = req.path:match("?encodedTrack=([^%s]+)")
  if not getEncode then
    return answer(json.encode({
      error = "Missing encodedTrack field"
    }), 400, {  ["Content-Type"] = "application/json" })
  end

  local encoded = require("url").decode(getEncode)

  local result, err = luna.sources:loadStream(encoded)

  if err then
    return answer(json.encode({
      error = err
    }), 400, {  ["Content-Type"] = "application/json" })
  end

  answer(json.encode(result), 200, {  ["Content-Type"] = "text/plain" })
end