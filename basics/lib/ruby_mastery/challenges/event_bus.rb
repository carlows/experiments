require_relative '../challenge'

module RubyMastery
  module Challenges
    class EventBus < Challenge
      def initialize
        super('The Event Bus (Callables)', '05_event_bus.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 5: THE EVENT BUS
          # ---------------------
          # Goal: Build a subscription system that handles different types of callables.
          #
          # Requirements:
          # 1. 'subscribe' should accept a block OR a proc/lambda.
          # 2. 'emit' should execute all subscribers for an event.
          # 3. You must demonstrate the difference between a Proc and a Lambda's return behavior.
          # 4. Use 'yield' for block-based execution.

          class EventBus
            def initialize
              @subscribers = Hash.new { |h, k| h[k] = [] }
            end

            def subscribe(event, callable = nil, &block)
              # TODO: Store the subscriber. It could be 'callable' or the 'block'.
            end

            def emit(event, *args)
              # TODO: Execute all subscribers for the event.
            end
          end

          # --- TEST SUITE ---
          bus = EventBus.new

          # 1. Test block subscription
          captured = nil
          bus.subscribe(:msg) { |data| captured = data }
          bus.emit(:msg, "hello")
          raise "Block subscription failed" unless captured == "hello"
          puts "✅ Block subscription passed"

          # 2. Test Proc vs Lambda return behavior
          # This is the tricky part.#{' '}
          # We want a subscriber that tries to 'return' early.

          def test_proc_behavior(bus)
            p = Proc.new { return "proc return" }
            bus.subscribe(:break, p)
            bus.emit(:break)
            "reached end"
          rescue LocalJumpError
            "jump error"
          end

          def test_lambda_behavior(bus)
            l = -> { return "lambda return" }
            bus.subscribe(:safe, l)
            bus.emit(:safe)
            "reached end"
          end

          # TODO: Explain why Proc causes an error or exits the method,#{' '}
          # while Lambda just exits the callable.

          # In this test, we expect the Proc to raise a LocalJumpError#{' '}
          # because it's being executed outside its original context.
          result_proc = test_proc_behavior(bus)
          raise "Proc behavior unexpected: \#{result_proc}" unless result_proc == "jump error"
          puts "✅ Proc LocalJumpError handled"

          result_lambda = test_lambda_behavior(bus)
          raise "Lambda behavior unexpected" unless result_lambda == "reached end"
          puts "✅ Lambda isolation passed"

          puts "✨ KATA COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `yield` vs `block.call`
          Using `yield` is generally faster because Ruby doesn't have to convert the block into a `Proc` object. However, if you need to store the block for later execution (like in this subscription system), you must use the `&block` syntax to capture it as a `Proc`.

          ### 2. Proc vs Lambda (The Return Trap)
          This is a classic "Expert" Ruby interview question.
          - **Proc**: `return` inside a Proc attempts to return from the **scope where the Proc was defined**. If that scope is gone or is the top-level, it raises a `LocalJumpError`.
          - **Lambda**: `return` inside a Lambda acts like a return from a method; it only exits the Lambda itself and returns control to the caller.#{' '}
          *Effective Ruby Item 14* - Prefer Lambdas when you need method-like behavior.

          ### 3. Argument Strictness
          Another difference not shown in the code but vital:
          - **Lambdas** are strict about arguments (like methods). If you pass 2 args to a 1-arg lambda, it raises `ArgumentError`.
          - **Procs** are loose. They ignore extra arguments and assign `nil` to missing ones.

          ### 4. `&block` Performance
          Capturing a block with `&block` creates a `Proc` object on the heap. In high-performance loops, this allocation overhead can add up. Expert Rubyists use `block_given?` and `yield` to avoid this unless storage is necessary.
        TEXT
      end
    end
  end
end
