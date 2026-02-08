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

          # 1. Registration
          verify_stage("Stage 1 (Inheritance Tracking)") do
            raise "Inheritance tracking failed" unless SmartRecord.all_models&.include?(User)
          end

          # 2. Schema
          verify_stage("Stage 2 (Schema Definition)") do
            u = User.new(id: 1)
            u.name = "Test"
            raise "Getter/Setter failed" unless u.name == "Test"
          end

          # 3. Method Missing
          verify_stage("Stage 3 (Dynamic Fallback)") do
            u = User.new(id: 1, age: 30)
            raise "Dynamic fallback failed" unless u.age == 30
          end

          # 4. Respond to Missing
          verify_stage("Stage 4 (respond_to_missing?)") do
            u = User.new(id: 1, age: 30)
            raise "respond_to? failed" unless u.respond_to?(:age)
            raise "method() lookup failed" unless u.method(:age).is_a?(Method)
          end

          # 5. Equality
          verify_stage("Stage 5 (Value Equality ==)") do
            u1 = User.new(id: 1, name: "A")
            u2 = User.new(id: 1, name: "B")
            raise "Equality mismatch" unless u1 == u2
            raise "Class mismatch" if u1 == SmartRecord.new(id: 1)
          end

          # 6. Hashing
          verify_stage("Stage 6 (eql? and hash)") do
            u1 = User.new(id: 1)
            u2 = User.new(id: 1)
            require 'set'
            set = Set.new([u1, u2])
            raise "Hash uniqueness failed (Set size \#{set.size})" if set.size != 1
            raise "eql? mismatch" unless u1.eql?(u2)
            raise "hash mismatch" unless u1.hash == u2.hash
          end

          # 7. Mass Assignment
          verify_stage("Stage 7 (Mass Assignment)") do
            u = User.new(id: 1)
            u.update_attributes(name: "Updated")
            raise "Update failed" unless u.name == "Updated"
          end

          # 8. Persistence
          verify_stage("Stage 8 (Persistence State)") do
            u = User.new(id: 1)
            raise "Should not be persisted" if u.persisted?
            u.save
            raise "Should be persisted" unless u.persisted?
          end

          # 9. JSON
          verify_stage("Stage 9 (JSON Serialization)") do
            u = User.new(id: 1, name: "JSON")
            json = u.as_json
            raise "JSON keys missing" unless json && json[:id] && json[:name]
          end

          # 10. Callbacks
          verify_stage("Stage 10 (Callbacks)") do
            class CallApp < SmartRecord; schema [:log]; end
            c = CallApp.new(id: 1)
            # We use singleton method to mock callback
            def c.run_callbacks; @attributes[:log] = "called"; end
            c.save
            raise "Callback not triggered" unless c.log == "called"
          end

          if @stages_passed == 10
            puts "\n🏆 ALL STAGES COMPLETE! You are a Meta-Programming Master."
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
