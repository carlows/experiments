require_relative 'connection'

class ConnectionManager
  def initialize
    @connections = {}
  end

  def add_connection(websocket_key, socket)
    STDERR.puts "Adding connection: #{ websocket_key.inspect }"
    @connections[websocket_key] = Connection.new(websocket_key, socket)
    @connections[websocket_key].listen
  end

  def broadcast_message(message)
    STDERR.puts "Broadcasting message: #{ message.inspect }"
    @connections.each do |_websocket_key, connection|
      response = Response.new(connection.socket)
      response.send_frame(message)
    end
  end
end