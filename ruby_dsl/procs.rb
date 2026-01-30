class MyClass
  @class_instance_variable = []

  def self.my_method
    yield 'hello world' if block_given?
  end

  def self.explicit_my_method(&block)
    @class_instance_variable << block
  end

  def self.print_class_instance_variable
    @class_instance_variable.size
  end

  def self.execute
    @class_instance_variable.each do |block|
      block.call('hello world')
    end
  end
end

MyClass.explicit_my_method do |arg|
  puts arg
end

puts MyClass.print_class_instance_variable

MyClass.explicit_my_method do |arg|
  puts arg * 2
end

puts MyClass.print_class_instance_variable

MyClass.execute

my_proc = Proc.new do |arg|
  puts "From proc: #{arg}"
end

MyClass.explicit_my_method(&my_proc)

puts MyClass.print_class_instance_variable

MyClass.execute

MyClass.my_method(&my_proc)
