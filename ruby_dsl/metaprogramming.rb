
class Test
  class << self
    def method
      # It gets defined as a class method in Test because it's the same as defining a method in class << self
      singleton_class.class_eval do
        def hello
          puts "Hello!"
        end
      end
    end

    def method_two
      # It gets defined as a class method of the metaclass of Test, so it's not directly a method of TEst
      singleton_class.instance_eval do
        def hello_two
          puts "Hello two!"
        end
      end
    end
  end
end


Test.method
Test.hello #> should work!
Test.hello_two #> should not work!
Test.singleton_class.hello_two #> should work!
# Mind fucking blowing!

# Also these two are equivalent! singleton_class allows you to get to the metaclass of the class
puts Test.singleton_class == (class << Test; self end) 
# Literally took me hours to understand why this was used here: https://github.com/rails/rails/blob/main/activesupport/lib/active_support/current_attributes.rb#L121
# I mean, I still don't know what it's being used for, but I'll get to that in the future :D