require_relative '../challenge'

module RubyMastery
  module Challenges
    class SafeSandbox < Challenge
      def initialize
        super('The Safe Sandbox (Bindings)', '09_safe_sandbox.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 9: THE SAFE SANDBOX
          # -----------------------
          # Goal: Evaluate a math formula string using a specific context.
          #
          # Requirements:
          # 1. Use 'Binding' to provide variables to the eval context.
          # 2. Prevent the eval from accessing local variables outside the sandbox.
          # 3. Use 'ERB' (optional) or just 'eval(code, binding)'.

          class Calculator
            def self.run(formula, variables = {})
              # TODO: Create a binding that contains ONLY the variables provided.
              # Execute the formula string inside that binding.
            end
          end

          # --- TEST SUITE ---
          vars = { x: 10, y: 5 }
          result = Calculator.run("x + y", vars)
          raise "Sandbox failed: x + y should be 15" unless result == 15
          puts "✅ Simple formula passed"

          # 2. Security Test: Isolation
          secret = "password123"
          begin
            # This should fail because 'secret' is not in the binding
            Calculator.run("secret", vars)
            raise "Security failure: Sandbox accessed outer scope!"
          rescue NameError
            puts "✅ Scope isolation passed"
          end

          # 3. Method isolation
          def should_not_be_callable
            "hacked!"
          end

          begin
            Calculator.run("should_not_be_callable", vars)
            raise "Security failure: Sandbox called private method!"
          rescue NameError
            puts "✅ Method isolation passed"
          end

          puts "✨ KATA COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. What is a `Binding`?
          A `Binding` object encapsulates the execution context at a particular place in your code. It keeps track of local variables, the value of `self`, and any available methods. When you call `eval(code, binding)`, you are telling Ruby to "pretend" it's running that code at the moment the binding was captured.

          ### 2. The `TOPLEVEL_BINDING`
          Ruby provides a constant `TOPLEVEL_BINDING` that represents the scope of the main file. Experts often use this to ensure they are evaluating code in a "clean" global scope rather than inside their class.

          ### 3. Creating Clean Bindings
          To create a truly isolated sandbox, you can define a class that inherits from `BasicObject`, instantiate it, and use its `binding` method. This ensures the code can't even call methods like `puts` or `exit` unless you explicitly provide them.

          ### 4. `eval` is Dangerous
          *Effective Ruby Item 33* - Avoid `eval` whenever possible. It is slow and a massive security risk. If a user can provide the string passed to `eval`, they can run `rm -rf /` on your server. Always sanitize input or use safer alternatives like `public_send` for dynamic method calls.
        TEXT
      end
    end
  end
end
