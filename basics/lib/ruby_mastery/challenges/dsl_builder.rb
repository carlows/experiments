require_relative '../challenge'

module RubyMastery
  module Challenges
    class DSLBuilder < Challenge
      def initialize
        super('The Mega DSL Builder (10-Stage Metaprogramming)', '07_dsl_builder.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 7: THE MEGA DSL BUILDER
          # ----------------------------
          # Goal: Build a clean, isolated Domain Specific Language.

          class DSL
            # 1. Basic Instance Eval: run a block in a context.
            def self.run(&block)
            end

            # 2. Argument Passing: Use 'instance_exec' to pass variables into the block.
            def self.run_with_args(*args, &block)
            end

            # 3. Clean Namespace: Inherit from 'BasicObject' to avoid Kernel method pollution.
            # 4. Method Missing Proxy: Redirect all unknown calls to a 'command' registry.
            # 5. Nested DSLs: Allow defining a 'config' block inside a 'server' block.
            # 6. Top-level constant access: Explain why BasicObject can't see 'String' or 'File'.
            # 7. Variable capturing: Ensure 'self' from the outer scope is still accessible.
            # 8. Syntax sugar: Implement 'method_missing' to create automatic getters/setters.
            # 9. Validation: Ensure the DSL doesn't allow calling dangerous methods like 'exit'.
            # 10. The Builder Pattern: Return an immutable object representing the final config.
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."
          # (DSL execution checks)
          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `BasicObject`
          Inheriting from `BasicObject` creates a "Blank Slate". It has almost no methods (no `puts`, no `nil?`, no `to_s`). This is essential for DSLs where you want any method name to be valid as a configuration key.

          ### 2. `instance_exec`
          Standard `instance_eval` doesn't take arguments. `instance_exec` allows you to pass local variables from your script into the "Magic" DSL block.

          ### 3. Scope Gates
          Constant lookup in Ruby follows a specific path. When you are inside a class or module, Ruby looks in the current scope first. Expert DSLs often use `::` to explicitly reference global constants when inside an isolated scope.
        TEXT
      end
    end
  end
end
