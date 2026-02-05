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
    @@subclasses << subclass
  end

  def self.all_models
    @@subclasses
  end

  def self.schema(fields)
    @fields = fields
    # TODO: Use metaprogramming (define_method) to create getters and setters
    # for each field in the schema.
    @fields.each do |field|
      define_method(field) do
        @attributes[field]
      end

      define_method("#{field}=") do |value|
        @attributes[field] = value
      end
    end
  end

  attr_accessor :id

  def initialize(id:, **attributes)
    @id = id
    @attributes = attributes
    # Validation: Ensure attributes match the schema
  end

  # TODO: Implement dynamic accessors using method_missing for 
  # fields NOT defined in schema but present in @attributes.
  # (Basically a fallback)
  def method_missing(method_name, *args)
    @attributes[method_name]
  end

  def respond_to_missing?(method_name, *args)
    @attributes.key?(method_name)
  end

  # TODO: Implement '==' for value equality.
  def ==(other)
    id == other.id && self.class == other.class
  end
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
