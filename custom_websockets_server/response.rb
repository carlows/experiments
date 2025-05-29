class Response
  def initialize(socket)
    @socket = socket
  end

  def send_frame(response)
    STDERR.puts "Sending response: #{response.inspect}"
    output = [0b10000001, response.size, response]
    @socket.write output.pack("CCA#{ response.size }")
  end
end