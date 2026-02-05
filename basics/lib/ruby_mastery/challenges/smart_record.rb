require_relative '../challenge'

module RubyMastery
  module Challenges
    class SmartRecord < Challenge
      def initialize
        super('The Mega Smart Record (10-Stage Meta-Model)', '01_smart_record.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 1: THE MEGA SMART RECORD
          # -----------------------------
          # Goal: Build a production-grade micro-ORM base class.

          class SmartRecord
            # 1. Registration: Track all subclasses in @@registry.
            def self.inherited(subclass)
            end

            def self.all_models
            end

            # 2. Schema Definition: Implement 'schema' to define getter/setters via define_method.
            def self.schema(fields)
            end

            attr_accessor :id

            def initialize(id:, **attributes)
              @id = id
              @attributes = attributes
            end

            # 3. Dynamic Fallback: Use method_missing to allow accessing @attributes#{' '}
            # NOT in the schema.
            def method_missing(method_name, *args, &block)
            end

            # 4. Expert Touch: Implement respond_to_missing? correctly.
            def respond_to_missing?(method_name, include_private = false)
            end

            # 5. Value Equality: Implement '==' for class + id check.
            def ==(other)
            end

            # 6. Type Safety: Implement 'eql?' and 'hash' so records work in Hashes/Sets.
            def eql?(other)
            end

            def hash
            end

            # 7. Mass Assignment: Implement a 'update_attributes' method.
            def update_attributes(new_attrs)
            end

            # 8. Persistence Simulation: Implement a 'save' method that returns true#{' '}
            # and a 'persisted?' check.
            def save
            end

            def persisted?
            end

            # 9. JSON Serialization: Implement 'as_json' including all attributes.
            def as_json
            end

            # 10. The Hook: Implement a 'before_save' callback system (conceptually).
            # For this kata, just call a method named 'run_callbacks' in save.
            def run_callbacks
            end
          end

          # --- TEST SUITE ---
          class User < SmartRecord
            schema [:name]
          end

          puts "Starting 10-Stage Verification..."

          # 1. Registry
          raise "Ex 1 Failed" unless SmartRecord.all_models.include?(User)
          puts "✅ Ex 1 Passed"

          # 3/4. Metaprogramming
          u = User.new(id: 1, age: 25)
          raise "Ex 3/4 Failed" unless u.age == 25 && u.respond_to?(:age)
          puts "✅ Ex 3/4 Passed"

          # 5/6. Equality
          u2 = User.new(id: 1)
          raise "Ex 5/6 Failed" unless u == u2 && [u, u2].uniq.size == 1
          puts "✅ Ex 5/6 Passed"

          # 9. JSON
          raise "Ex 9 Failed" unless u.as_json.key?(:name)
          puts "✅ Ex 9 Passed"

          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The Power of `inherited`
          Subclass tracking is the secret sauce of Rails. It allows the framework to discover your models without you ever mentioning them in a config file.

          ### 2. `define_method` vs `method_missing`
          Standard practice: Use `define_method` for things you know ahead of time (Schema) for performance. Use `method_missing` for the unknown (OpenStruct behavior).

          ### 3. Identity vs Value
          Expert Rubyists know that `==`, `eql?`, and `equal?` serve different purposes. Overriding `hash` alongside `eql?` is the only way to make your objects behave correctly when used as keys in a `Hash`.
        TEXT
      end
    end
  end
end
