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
          # Goal: Build a micro-ORM base class.
          #
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
            end

            # TODO: Implement dynamic accessors using method_missing for#{' '}
            # fields NOT defined in schema but present in @attributes.
            # (Basically a fallback)

            # TODO: Implement '==' for value equality.
            # Two records should be equal if they have the same class AND same id.
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
          ### 1. The Inheritance Hook (`self.inherited`)
          In Ruby, `inherited` is a callback triggered whenever a class is subclassed. This is a powerful "Expert" pattern used by frameworks like Rails (ActiveRecord) and Sequel to maintain a registry of models without requiring manual registration. It allows the base class to "know" about its children, enabling features like `SmartRecord.all_models`.

          ### 2. `define_method` vs `method_missing`
          We used both here for different reasons:
          - **`define_method`**: Used for schema fields. This is "Eager Metaprogramming." Once defined, these methods exist on the class and are just as fast as regular `def` methods.
          - **`method_missing`**: Used for fallback attributes. This is "Lazy Metaprogramming." It's slower because Ruby has to exhaust the method lookup chain before calling it, but it provides ultimate flexibility for data that doesn't fit a strict schema.

          ### 3. The `respond_to_missing?` Mandate
          *Effective Ruby Item 31* states: "Always call `respond_to_missing?` when overriding `method_missing`."#{' '}
          If you don't, your object might answer a method call (via `method_missing`), but `object.respond_to?(:method)` will return `false`. This breaks libraries that check for method existence before calling them (like `Object#method` or delegators).

          ### 4. Equality and the Identity Crisis
          By default, Ruby's `==` (inherited from `Object`) checks **object identity** (whether two variables point to the same spot in memory). In ORMs and Domain Driven Design, we often want **value equality**. We override `==` so that two different objects representing the same record (same ID) are treated as equal.#{' '}
          *Note:* If you override `==`, you should usually override `eql?` and `hash` as well if you plan to use these objects as Hash keys.
        TEXT
      end
    end
  end
end
