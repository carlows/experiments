require_relative '../challenge'

module RubyMastery
  module Challenges
    class DSLBuilder < Challenge
      def initialize
        super('The DSL Builder (Contexts)', '07_dsl_builder.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 7: THE DSL BUILDER
          # ----------------------
          # Goal: Build a Domain Specific Language for defining a "Robot".
          #
          # Requirements:
          # 1. Use 'instance_eval' to execute a block inside the context of a Robot.
          # 2. Allow defining 'commands' dynamically.
          # 3. Prevent the DSL from polluting the global namespace.

          class Robot
            attr_reader :actions

            def initialize
              @actions = []
            end

            def move(direction)
              @actions << "Moving \#{direction}"
            end

            def self.define_dsl(&block)
              # TODO: Create a new robot and execute the block#{' '}
              # inside that robot's instance context.
            end

            # TODO: Add a way to define custom commands like 'jump'#{' '}
            # that just add the command name to @actions.
          end

          # --- TEST SUITE ---
          robot = Robot.define_dsl do
            move "North"
            move "South"
            # jump  # This should work after you implement dynamic commands
          end

          raise "DSL failed: No actions recorded" if robot.actions.empty?
          raise "DSL failed: Incorrect actions" unless robot.actions == ["Moving North", "Moving South"]
          puts "✅ Basic DSL passed"

          # Challenge: Dynamic Commands
          # We want to be able to call 'jump', 'dance', etc. inside the DSL
          # without explicitly defining methods for them.

          robot2 = Robot.define_dsl do
            move "East"
            # jump
            # dance
          end

          # Adjust the test below once you implement the dynamic part
          # raise "Dynamic DSL failed" unless robot2.actions.include?("jump")

          puts "✨ KATA COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `instance_eval` vs `yield(self)`
          - `yield(self)`: The block is executed in the *caller's* context. You have to write `robot.move`.
          - `instance_eval`: The block is executed in the *receiver's* context. You can just write `move`.
          *Effective Ruby Item 34* - Use `instance_eval` for "Clean DSLs" where you want the code to look like a configuration file.

          ### 2. Context Pollution
          The downside of `instance_eval` is that the block loses access to the variables and methods of its original scope (where the block was written). Expert DSL designers often use `instance_exec` instead, which allows passing arguments from the outer scope into the inner context.

          ### 3. `class_eval` vs `instance_eval`
          - `class_eval` (or `module_eval`): Operates on the class level. Use it to add instance methods to a class.
          - `instance_eval`: Operates on a specific object instance. If called on a Class object, it adds *class methods*.

          ### 4. BlankSlate
          In advanced DSLs, you want to avoid name collisions with methods like `display`, `test`, or `type` (which are inherited from `Kernel`). Experts often make the DSL evaluator inherit from `BasicObject` instead of `Object` to create a "Blank Slate".
        TEXT
      end
    end
  end
end
