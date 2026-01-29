module AncestorA
  def self.extended(target)
    puts "#{self} has been extended!"
  end

  def hello
    puts "hello from #{self}"
  end
end

module AncestorB
  def world
    puts "world from #{self}"
  end
end

class AncestorC
  private

  def hello
    puts 'hello'
  end

  protected

  def world
    puts 'world'
  end
end

class Child
  extend AncestorA
  extend AncestorB
end

class AnotherChild
  include AncestorA
  prepend AncestorA
end

# cannot subclass a module
# class ClassA < AncestorA
# end

class ClassA < AncestorC
  def test
    # possible to access both
    puts "#{hello} #{world}"
  end

  def print_from_hello(other)
    # we CANT access private methods from OTHER instances
    other.hello
  end

  def print_from_world(other)
    # but we CAN access protected methods form other instances
    # useful for comparison between class instances
    other.world
  end
end

ClassA.new.test
# ClassA.new.print_from_hello(ClassA.new)
ClassA.new.print_from_world(ClassA.new)

# No method because extend adds them to the singleton object of Child
# Child.new.test
Child.hello
Child.world

# No method because include adds them ass instance methods
# AnotherChild.hello
AnotherChild.new.hello


puts "ancestors of classA: #{ClassA.ancestors}"
# The extended methods appear only in the singleton class ancestors
# Thus they're not part of the ancestors chain
puts "ancestors of child: #{Child.singleton_class.ancestors}"

puts "ancestors of another child: #{AnotherChild.ancestors}"
