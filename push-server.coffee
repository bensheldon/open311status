express = require 'express'
sockjs = require 'sockjs'
http = require 'http'

unless process.env.NODE_ENV?
  process.env.NODE_ENV = 'development'

if process.env.NODE_ENV in ['development', 'test']
  PORT = process.env.NODE_PORT || 3001
else
  PORT = process.env.PORT

# TODO: add postgres
# http://stackoverflow.com/questions/8262375/listen-query-timeout-with-node-postgres

# 1. Sockjs server
sockjs_server = sockjs.createServer()
sockjs_server.on 'connection', (conn) ->
  conn.on 'data', (message) ->
    conn.write message

# 2. Express server
app = express()
server = http.createServer(app)
sockjs_server.installHandlers server,
  prefix: '/echo'

# 3. Start server
server.listen PORT, ->
  console.log "Node Server listening port=#{ PORT }"

app.get '/', (req, res) ->
  res.json status: 'ok'
