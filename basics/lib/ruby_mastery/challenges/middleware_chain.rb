require_relative '../challenge'

module RubyMastery
  module Challenges
    class MiddlewareChain < Challenge
      def initialize
        super('The Middleware Chain (Hierarchy & AOP)', '03_middleware_chain.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 3: THE MIDDLEWARE CHAIN
          # ---------------------------
          # Implement a system where modules can "wrap" method behavior using 'prepend'.
          # This is the basis for modern Ruby performance monitoring and logging tools.

          module LoggerMiddleware
            def call(env)
              puts "LOG: Calling \#{self.class}"
              # TODO: Call the original method.#{' '}
              # Hint: Use 'super'
            end
          end

          module TracerMiddleware
            def call(env)
              env[:trace] << self.class.name
              # TODO: Call original method.#{' '}
              # EXPERT GOTCHA: If you use 'super' vs 'super(env)', what happens?
              # Ensure 'env' is passed correctly.
            end
          end

          class FinalApp
            def call(env)
              env[:status] = 200
              "Result from App"
            end
          end

          # --- YOUR TASK ---
          # 1. Update LoggerMiddleware and TracerMiddleware to use 'super' correctly.
          # 2. Use 'prepend' to add LoggerMiddleware and TracerMiddleware to FinalApp.
          # 3. Add a singleton method to a specific instance of FinalApp.

          # TODO: Modify FinalApp here
          # class FinalApp
          #   prepend ...
          # end

          # --- TEST SUITE ---
          app = FinalApp.new
          env = { trace: [] }

          result = app.call(env)

          raise "Middleware failure: Status not set" unless env[:status] == 200
          raise "Middleware failure: Tracer not called" unless env[:trace].include?("FinalApp") # (Wait, TracerMiddleware adds its name)

          # 4. Singleton Class Challenge
          # Add a method called 'version' ONLY to this specific 'app' instance
          # using the singleton class syntax.

          # TODO: Add 'version' to 'app'

          begin
            raise "Singleton failure" unless app.version == "1.0.0"
            raise "Singleton leaking" if FinalApp.new.respond_to?(:version)
            puts "✅ Singleton method passed"
          rescue NoMethodError
            raise "Singleton failure: version method not found"
          end

          puts "✨ KATA COMPLETE: You mastered the Hierarchy!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          1. **Prepend vs Include**: `include` inserts a module *after* the class in the ancestor chain. `prepend` inserts it *before* the class, allowing the module to override class methods and call `super` to reach the original implementation.
          2. **super vs super()**: *Effective Ruby Item 11* - `super` (no parens) passes ALL arguments to the parent method automatically. `super()` (with parens) passes NO arguments. Being explicit is often safer.
          3. **Singleton Class (`class << self`)**: Every object in Ruby has a hidden "eigenclass". Modifying it allows you to define behavior that doesn't leak to other instances of the same class.
          4. **Method Lookup**: Understanding the path (Prepend -> Class -> Include -> Superclass) is the key to debugging complex Ruby frameworks.
        TEXT
      end
    end
  end
end
