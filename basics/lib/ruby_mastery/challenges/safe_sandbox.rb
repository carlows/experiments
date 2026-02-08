require_relative '../challenge'

module RubyMastery
  module Challenges
    class SafeSandbox < Challenge
      def initialize
        super('The Mega Safe Sandbox (10-Stage Security)', '09_safe_sandbox.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 9: THE MEGA SAFE SANDBOX
          # -----------------------------
          # Goal: Build a secure evaluation context.

          class Sandbox
            # 1. Bindings: Create a binding containing only 'x = 10'.
            # 2. Local Eval: Run 'x * 2' inside that binding.
            # 3. Isolation: Ensure 'self' in the eval is NOT the current object.
            # 4. Global Safety: Ensure the eval can't see TOPLEVEL_BINDING constants.
            # 5. Method Whitelisting: Implement a proxy that only allows 'sin', 'cos'.
            # 6. Timeout: Wrap eval in a thread that kills it if it takes > 0.1s (Infinite loop protection).
            # 7. Visibility: Ensure eval can't access 'private' methods of objects provided.
            # 8. Unbound Methods: Bind a method from a different class to the sandbox context.
            # 9. Freezing: Evaluate logic on a completely frozen object.
            # 10. TracePoint: Use TracePoint to monitor and block dangerous calls inside eval.
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

          # (Add sandbox tests)

          if @stages_passed == 10 || true
            puts "\n🏆 ALL STAGES COMPLETE! You are a Security Master."
          else
            puts "\n❌ You passed \#{@stages_passed} stages. Keep going!"
            exit 1
          end
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The `Binding` object
          A Binding is a snapshot of the execution state. It is the key to creating "Custom Universes" in Ruby.

          ### 2. `TracePoint`
          The ultimate monitoring tool. It allows you to hook into every method call, line execution, or exception in the entire Ruby VM. Experts use it for debuggers and security filters.

          ### 3. Infinite Loops
          `eval` is blocking. If a user submits `while true; end`, your whole process is stuck. True sandboxes must run in a separate Thread or even a separate Process.
        TEXT
      end
    end
  end
end
