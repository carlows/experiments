require_relative '../challenge'

module RubyMastery
  module Challenges
    class MicroServer < Challenge
      def initialize
        super('The Micro-Web Server (Rack)', '10_micro_server.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 10: THE MICRO-WEB SERVER
          # ----------------------------
          # Goal: Implement the Rack interface to build a tiny web app.
          #
          # Requirements:
          # 1. A Rack app must be an object that responds to 'call'.
          # 2. 'call' receives an 'env' hash.
          # 3. 'call' must return an array: [status, headers, body].
          # 4. Implement a simple router inside your 'call' method.

          class MyTinyApp
            def call(env)
              path = env["PATH_INFO"]
              # TODO: Implement routing
              # / -> Status 200, Body ["Welcome"]
              # /hello -> Status 200, Body ["Hello World"]
              # anything else -> Status 404, Body ["Not Found"]
            end
          end

          # --- TEST SUITE ---
          app = MyTinyApp.new

          # 1. Test Home
          status, headers, body = app.call({ "PATH_INFO" => "/" })
          raise "Rack failure: status should be 200" unless status == 200
          raise "Rack failure: body should be Enumerable" unless body.respond_to?(:each)
          raise "Rack failure: body content mismatch" unless body.first == "Welcome"
          puts "✅ Root path passed"

          # 2. Test Hello
          status, _, body = app.call({ "PATH_INFO" => "/hello" })
          raise "Rack failure: status should be 200" unless status == 200
          raise "Rack failure: body content mismatch" unless body.first == "Hello World"
          puts "✅ Hello path passed"

          # 3. Test 404
          status, _, _ = app.call({ "PATH_INFO" => "/unknown" })
          raise "Rack failure: status should be 404" unless status == 404
          puts "✅ 404 handling passed"

          puts "✨ KATA COMPLETE: You built a Rack app!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The Rack Interface
          Rack is the "thin" layer that sits between your Ruby code and the web server (like Puma or Unicorn). Every major Ruby framework (Rails, Sinatra, Hanami) is just a complex Rack application. The contract is simple: an object with a `call` method that returns a specific 3-element array.

          ### 2. The `env` Hash
          This hash contains everything about the request: headers, query parameters, the request method (GET/POST), and server-specific variables. Parsing this hash manually is how you build a router.

          ### 3. Why the Body must be Enumerable?
          Rack requires the body (the 3rd element) to respond to `each`. This is because the server might want to stream the response to the client in chunks (e.g., for large files or Server-Sent Events). Even if you only have a single string, you must wrap it in an array like `["Hello"]`.

          ### 4. Middleware Stacks
          Expert Rubyists use `Rack::Builder` to stack middleware. Middleware is just a Rack app that wraps another Rack app. This is how features like logging, sessions, and authentication are added to applications in a decoupled way.
        TEXT
      end
    end
  end
end
