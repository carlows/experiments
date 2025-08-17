class MyDSL
  attr_accessor :commands_ran

  def initialize
    @commands_ran = []
  end

  def self.run(title, &block)
    new.report(title, &block)
  end

  def say_hello
    commands_ran << "say_hello"
    puts "Hello!"
  end

  def say_goodbye
    commands_ran << "say_goodbye"
    puts "Goodbye!"
  end

  def report(title, &block)
    puts "Title: #{title}"
    instance_eval(&block)
    puts "Commands run: #{commands_ran.join(", ")}"
  end
end

MyDSL.run("My Report") do
  say_hello
  say_goodbye
  8.times { say_hello }
end
