return [[
server:
  host: "127.0.0.1"
  port: 3000
  password: "youshallnotpass"

luna:
  soundcloud: true
  bandcamp: true

sources:
  fallbackSearchSource: 'bandcamp'
  maxSearchResults: 25
  soundcloud:
    fallbackIfSnipped: false

logger:
  request:
    enable: true
    withHeader: false
]]