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

          # --- TEST SUITE ---
          app = FinalApp.new
          env = { trace: [] }

          # Need to make sure the prepend is applied before calling
          # (You might need to reopen the class or use an instance-level trick)

          result = app.call(env)

          raise "Middleware failure: Status not set" unless env[:status] == 200
          raise "Middleware failure: Tracer not called" unless env[:trace].include?("FinalApp")

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
          ### 1. `include` vs `prepend`
          - `include`: Inserts the module **after** the class in the ancestor chain. If the class defines a method, it "wins" over the module.
          - `prepend`: Inserts the module **before** the class. This allows the module to override the class's methods and then use `super` to call the original implementation. This is the foundation of "Aspect-Oriented Programming" in Ruby.

          ### 2. `super` vs `super()`
          *Effective Ruby Item 11* - `super` (no parentheses) automatically forwards all arguments from the current method to the parent. `super()` (with parentheses) forwards nothing.#{' '}
          In a middleware chain, you usually want `super` to ensure the `env` hash (and any future arguments) flows through every layer correctly.

          ### 3. The Singleton Class (Eigenclass)
          Every object in Ruby has its own "Singleton Class" (or Eigenclass). When you define a method on a specific instance (`def app.version`), you are actually adding that method to its singleton class, not its regular class.#{' '}
          *Expert Syntax:* `class << app; def version; "1.0.0"; end; end`.

          ### 4. Method Lookup Chain
          When you call a method, Ruby searches:#{' '}
          1. Singleton Class
          2. Prepended Modules (in reverse order of prepending)
          3. The Class itself
          4. Included Modules (in reverse order of inclusion)
          5. Superclass -> Prepends -> Includes...
          6. `Object` -> `Kernel` -> `BasicObject`
          7. `method_missing`
          Understanding this "Path of Power" is what separates Ruby juniors from seniors.
        TEXT
      end
    end
  end
end
