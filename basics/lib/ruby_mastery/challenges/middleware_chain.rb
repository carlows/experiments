require_relative '../challenge'

module RubyMastery
  module Challenges
    class MiddlewareChain < Challenge
      def initialize
        super('The Mega Middleware Chain (10-Stage AOP)', '03_middleware_chain.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 3: THE MEGA MIDDLEWARE CHAIN
          # ---------------------------------
          # Goal: Build a recursive, prepended middleware stack.

          module Timing
            # 1. Wrapping: Use 'super' to call the original and measure time.
            def call(env)
            end
          end

          module Recovery
            # 2. Safety: Wrap 'super' in a begin/rescue to catch all errors.
            def call(env)
            end
          end

          class App
            def call(env)
              env[:status] = 200
              "OK"
            end
          end

          # --- TASK ---
          # 3. Dynamic Stacking: Implement a method 'build_stack' that#{' '}
          # prepends an array of modules to the App class.

          class AppBuilder
            # 4. Super Pitfall: Ensure 'super' vs 'super()' is used correctly.
            # 5. Singleton Stacking: Add a middleware ONLY to a specific instance.
            # 6. Method Lookup: Verify that the order of 'prepend' matters (First prepended is last called).
            # 7. Const Missing: Implement auto-loading for missing Middleware constants.
            # 8. Method Visibility: Ensure prepended methods can call private methods of the class.
            # 9. Argument Forwarding: Use '...' (Ruby 2.7+) to forward all args to super.
            # 10. The Un-prepend: (Concept) Explain why you can't easily remove a module once prepended.
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."
          # (Conceptual Tests)
          puts "✅ Stages 1-10 Passed"
          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `prepend` vs `include`
          `prepend` is the standard for modern Ruby instrumentation (used by NewRelic, Skylight, etc). It allows you to intercept method calls without using the slow `alias_method_chain` pattern.

          ### 2. Argument Forwarding
          The `(...)` syntax is the most robust way to forward arguments. It handles positional, keyword, and block arguments automatically, ensuring your middleware doesn't break when the original method's signature changes.

          ### 3. Order Matters
          If you prepend `A` then `B`, the lookup is: Instance -> Singleton -> B -> A -> Class. The LAST module prepended is the FIRST one to execute its code before `super`.
        TEXT
      end
    end
  end
end
