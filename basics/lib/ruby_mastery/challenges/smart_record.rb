require_relative '../challenge'

module RubyMastery
  module Challenges
    class SmartRecord < Challenge
      def initialize
        super('The Smart Record (Meta-Model)', '01_smart_record.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 1: THE SMART RECORD
          # ------------------------
          # In this kata, you will build a micro-ORM base class.
          # Requirements:
          # 1. Attributes should be dynamic based on a 'schema' hash.
          # 2. You must implement custom equality (==) so records with the same ID and class are equal.
          # 3. You must use 'inherited' hook to track all subclasses of SmartRecord.
          # 4. Expert touch: Implement respond_to_missing? correctly.

          class SmartRecord
            @@subclasses = []

            def self.inherited(subclass)
              # TODO: Track the subclass in @@subclasses
            end

            def self.all_models
              @@subclasses
            end

            def self.schema(fields)
              @fields = fields
              # TODO: Use metaprogramming (define_method) to create getters and setters
              # for each field in the schema.
            end

            attr_accessor :id

            def initialize(id:, **attributes)
              @id = id
              @attributes = attributes
              # Validation: Ensure attributes match the schema
            end

            # TODO: Implement dynamic accessors using method_missing for#{' '}
            # fields NOT defined in schema but present in @attributes.
            # (Basically a fallback)

            # TODO: Implement '==' for value equality.
          end

          # --- TEST SUITE ---
          class User < SmartRecord
            schema [:name, :email]
          end

          class Post < SmartRecord; end

          # 1. Test inheritance tracking
          raise "Inheritance tracking failed" unless SmartRecord.all_models.include?(User)
          raise "Inheritance tracking failed" unless SmartRecord.all_models.include?(Post)
          puts "✅ Inheritance tracking passed"

          # 2. Test schema-defined methods
          u1 = User.new(id: 1)
          u1.name = "Alice"
          raise "Schema method failed" unless u1.name == "Alice"
          puts "✅ Schema methods passed"

          # 3. Test equality
          u2 = User.new(id: 1)
          raise "Equality failed (Value Object pattern)" unless u1 == u2
          raise "Equality should check class" if u1 == SmartRecord.new(id: 1)
          puts "✅ Equality logic passed"

          # 4. Test method_missing fallback
          u3 = User.new(id: 3, age: 30)
          begin
            raise "method_missing fallback failed" unless u3.age == 30
            raise "respond_to_missing? failed" unless u3.respond_to?(:age)
            puts "✅ Metaprogramming fallback passed"
          rescue NoMethodError
            raise "Metaprogramming fallback failed: age method not found"
          end

          puts "✨ KATA COMPLETE: You have built a Smart Record!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          1. **Inheritance Hooks (`self.inherited`)**: Expert Rubyists use this to build registries (like ActiveRecord does for models).
          2. **define_method vs method_missing**: We used `define_method` for schema fields (fast) and `method_missing` for dynamic attributes (flexible).#{' '}
          3. **respond_to_missing?**: *Effective Ruby Item 31* - Always implement this when using `method_missing` so that `method()` and `respond_to?` work correctly.
          4. **Value Equality (`==`)**: By default, `==` checks object identity. Overriding it allows your objects to behave like values (crucial for DDD and testing).
        TEXT
      end
    end
  end
end
