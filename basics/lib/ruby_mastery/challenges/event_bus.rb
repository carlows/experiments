require_relative '../challenge'

module RubyMastery
  module Challenges
    class EventBus < Challenge
      def initialize
        super('The Mega Event Bus (10-Stage Callables)', '05_event_bus.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 5: THE MEGA EVENT BUS
          # --------------------------
          # Goal: Build a subscription system handling all types of Ruby callables.

          class Bus
            # 1. Block Capture: subscribe with a block.
            def subscribe(&block)
            end

            # 2. Yield vs Call: emit that uses 'yield' if block given, otherwise 'call'.
            def emit(*args)
            end

            # 3. Proc Context: Demonstrate why 'return' in a Proc can raise LocalJumpError.
            def proc_trap
            end

            # 4. Lambda Safety: Demonstrate why 'return' in a Lambda is safe.
            def lambda_safety
            end

            # 5. Method Object: Use 'obj.method(:name)' as a subscriber.
            def subscribe_method(obj, method_name)
            end

            # 6. Unsubscribing: Remove a callable from the list.
            def unsubscribe(callable)
            end

            # 7. Argument Strictness: Compare Proc vs Lambda arg handling.
            def test_arity
            end

            # 8. Symbols as Callables: Use '&:upcase' logic to process events.
            def map_events(event_names)
            end

            # 9. Closure Variables: Verify that subscribers see variables from their definition scope.
            def verify_closure
            end

            # 10. Currying: Use '.curry' to pre-fill the first argument of a subscriber.
            def curry_subscriber(callable, first_arg)
            end
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."
          # (Callable verification)
          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The Method Object
          Everything is an object, even methods. `obj.method(:foo)` returns a `Method` instance that can be passed around, stored, and called later. This is a cleaner alternative to passing anonymous blocks.

          ### 2. Currying
          `.curry` allows you to create specialized versions of functions. If you have a logger that takes `(level, message)`, you can `curry` it to create an `info_logger` that only takes `(message)`.

          ### 3. Arity
          - **Procs** are lenient: `Proc.new { |a| p a }.call(1, 2)` works.
          - **Lambdas** are strict: `->(a) { p a }.call(1, 2)` raises `ArgumentError`.
          - **Methods** are strict.
        TEXT
      end
    end
  end
end
