class Connection
  attr_reader :websocket_key, :socket

  def initialize(websocket_key, socket)
    @websocket_key = websocket_key
    @socket = socket
  end

  def listen
    Thread.new do
      loop do
        handle_next_frame
      end
    end
  end

  def handle_next_frame
    first_byte = @socket.getbyte
    fin = first_byte & 0b10000000
    opcode = first_byte & 0b00001111
    STDERR.puts "First byte: #{ first_byte }"
    STDERR.puts "FIN: #{ fin }"
    STDERR.puts "OPCODE: #{ opcode }"

    raise "We don't support continuations" unless fin
    raise "We only support opcode 1" unless opcode == 1

    second_byte = @socket.getbyte
    is_masked = second_byte & 0b10000000
    payload_size = second_byte & 0b01111111

    raise "All frames sent to a server should be masked according to the websocket spec" unless is_masked
    raise "We only support payloads < 126 bytes in length" unless payload_size < 126

    STDERR.puts "Payload size: #{ payload_size } bytes"

    mask = 4.times.map { @socket.getbyte }
    STDERR.puts "Got mask: #{ mask.inspect }"

    data = payload_size.times.map { @socket.getbyte }
    STDERR.puts "Got masked data: #{ data.inspect }"

    unmasked_data = data.each_with_index.map { |byte, i| byte ^ mask[i % 4] }
    STDERR.puts "Unmasked the data: #{ unmasked_data.inspect }"

    message_router(unmasked_data.pack('C*').force_encoding('utf-8'))
  end

  def message_router(unmasked_data)
    STDERR.puts "Routing message: #{ unmasked_data.inspect }"
    case unmasked_data
    when "Ping!"
      response = Response.new(@socket)
      response.send_frame("Pong!")
    else
      STDERR.puts "Unknown message: #{ unmasked_data.inspect }"
    end
  end
end