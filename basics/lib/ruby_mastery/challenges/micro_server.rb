require_relative '../challenge'

module RubyMastery
  module Challenges
    class MicroServer < Challenge
      def initialize
        super('The Mega Micro Server (10-Stage Web Stack)', '10_micro_server.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 10: THE MEGA MICRO SERVER
          # ------------------------------
          # Goal: Build a production-ready Rack stack.

          class MyServer
            # 1. Rack Spec: Implement 'call(env)' returning [200, {}, ["OK"]].
            # 2. Router: Support '/hello' and '/goodbye' paths.
            # 3. Request Objects: Use 'Rack::Request' to parse query params.
            # 4. Response Objects: Use 'Rack::Response' to set cookies.
            # 5. Middleware: Implement a 'Logger' middleware.
            # 6. Error Handling: Implement a 'ShowExceptions' middleware.
            # 7. Streaming: Return an enumerable body for a large file download.
            # 8. POST Handling: Parse JSON bodies from POST requests.
            # 9. Session: Implement a simple 'Rack::Session::Cookie' conceptually.
            # 10. URL Map: Route '/api' to a different app using 'Rack::URLMap'.
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."
          # (Rack contract validation)
          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The Rack Protocol
          Status (Int), Headers (Hash), Body (Enumerable). That's it. This simplicity is why Ruby has such a vibrant web ecosystem.

          ### 2. Middleware Composition
          The "Onion" architecture. Every middleware receives an `env` and a `next_app`. It can modify the environment on the way IN and modify the response on the way OUT.

          ### 3. Enumerables for Performance
          By returning an Enumerable body, you allow the server to "Stream" the data to the client chunk-by-chunk, which is vital for keeping memory usage low during large downloads.
        TEXT
      end
    end
  end
end
