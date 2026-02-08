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

          # --- TEST SUITE (DO NOT MODIFY) ---
          @stages_passed = 0
          def verify_stage(name)
            yield
            puts "✅ \#{name} Passed"
            @stages_passed += 1
          rescue => e
            puts "❌ \#{name} Failed: \#{e.message}"
          end

          puts "Starting 10-Stage Verification..."

          # 1. Block
          verify_stage("Stage 1 (Block Capture)") do
            bus = Bus.new
            bus.subscribe { "hit" }
            # (check if block stored)
          end

          # 2. Emit
          verify_stage("Stage 2 (Emit)") do
            bus = Bus.new
            captured = nil
            bus.subscribe { |v| captured = v }
            bus.emit("data")
            raise "Emit failed" unless captured == "data"
          end

          # 3. Proc Trap
          verify_stage("Stage 3 (Proc Context)") do
            bus = Bus.new
            def trigger_proc(bus)
              p = Proc.new { return "early" }
              bus.subscribe(&p)
              bus.emit
              "end"
            rescue LocalJumpError
              "trap"
            end
            raise "Proc should cause LocalJumpError when calling return" unless trigger_proc(bus) == "trap"
          end

          # 4. Lambda Safety
          verify_stage("Stage 4 (Lambda Safety)") do
            bus = Bus.new
            def trigger_lambda(bus)
              l = -> { return "early" }
              bus.subscribe(&l)
              bus.emit
              "end"
            end
            raise "Lambda should NOT cause LocalJumpError" unless trigger_lambda(bus) == "end"
          end

          # 5. Method Object
          verify_stage("Stage 5 (Method Object)") do
            bus = Bus.new
            obj = Object.new
            def obj.on_event(val); @val = val; end
            bus.subscribe_method(obj, :on_event)
            bus.emit("method")
            raise "Method call failed" unless obj.instance_variable_get(:@val) == "method"
          end

          # 6. Unsubscribe
          verify_stage("Stage 6 (Unsubscribing)") do
            bus = Bus.new
            l = ->(v) { @val = v }
            bus.subscribe(&l)
            bus.unsubscribe(l)
            bus.emit("lost")
            raise "Unsubscribe failed" if @val == "lost"
          end

          # 7. Arity
          verify_stage("Stage 7 (Arity)") do
            bus = Bus.new
            # Verification of arity logic if they implemented it
          end

          # 8. Symbols
          verify_stage("Stage 8 (Symbols)") do
            bus = Bus.new
            res = bus.map_events(["a", "b"])
            raise "Symbol mapping failed" unless res == ["A", "B"]
          end

          # 9. Closures
          verify_stage("Stage 9 (Closures)") do
            bus = Bus.new
            x = 1
            bus.subscribe { x = 2 }
            bus.emit
            raise "Closure capture failed" unless x == 2
          end

          # 10. Currying
          verify_stage("Stage 10 (Currying)") do
            bus = Bus.new
            calc = ->(a, b) { a + b }
            curried = bus.curry_subscriber(calc, 10)
            raise "Currying failed" unless curried.call(5) == 15
          end

          if @stages_passed == 10
            puts "\n🏆 ALL STAGES COMPLETE! You are a Callable Master."
          else
            puts "\n❌ You passed \#{@stages_passed}/10 stages. Keep going!"
            exit 1
          end
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
