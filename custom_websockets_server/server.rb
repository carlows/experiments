require 'socket'
require 'digest'
require_relative 'response'
require_relative 'connection_manager'

server = TCPServer.new('localhost', 2345)
connection_manager = ConnectionManager.new

# Mozilla docs on websocket servers: https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers#reading_and_unmasking_the_data
loop do
  socket = server.accept
  STDERR.puts "Incoming request!!"
  
  http_request = ""
  while ((line = socket.gets) && line != "\r\n")
    http_request += line
  end
  STDERR.puts http_request

  # Check for Content-Length to read the body
  content_length = 0
  if matches = http_request.match(/^Content-Length: (\d+)/i)
    content_length = matches[1].to_i
    STDERR.puts "Content-Length: #{content_length}"
  end

  # Read the body if there is one
  body = ""
  if content_length > 0
    body = socket.read(content_length)
    STDERR.puts "Request body: #{body.inspect}"
  end

  # Grab the security key from the headers.
  # If one isn't present, close the connection.
  if matches = http_request.match(/^Sec-WebSocket-Key: (\S+)/)
    websocket_key = matches[1]
    STDERR.puts "Websocket handshake detected with key: #{ websocket_key }"
  else
    # This is the POST request coming from the client. We're simply broadcasting a message to all connected clients.
    connection_manager.broadcast_message(body)
    socket.write("HTTP/1.1 200 OK\r\n\r\n")
    socket.close
    next
  end

  # TODO: does it matter to the browser what key we use here?
  response_key = Digest::SHA1.base64digest([websocket_key, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"].join)
  STDERR.puts "Responding to handshake with key: #{ response_key }"

  response = "HTTP/1.1 101 Switching Protocols\r\n"
  response += "Upgrade: websocket\r\n"
  response += "Connection: Upgrade\r\n"
  response += "Sec-WebSocket-Accept: #{response_key}\r\n"
  response += "\r\n"
  
  socket.write(response)

  STDERR.puts "Handshake completed. Starting to parse the websocket frame."

  connection_manager.add_connection(websocket_key, socket)
end
