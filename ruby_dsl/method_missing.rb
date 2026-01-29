require 'benchmark'

class WithMethodDefinition
  def initialize(data)
    @data = data
  end

  def simple_method
    42
  end
end

class WithMethodMissing
  def initialize(data)
    @data = data
  end

  def method_missing(method_name, *_args)
    @data[method_name.to_sym]
  end
end

class WithMethodMissingDefiningMethod
  def initialize(data)
    @data = data
  end

  def method_missing(method_name, *args)
    if @data.key?(method_name.to_sym)
      self.class.define_method(method_name) { @data[method_name.to_sym] }
      send(method_name)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @data.key?(method_name.to_sym) || super
  end
end

data = { test: 42, hello: 'world' }

Benchmark.bmbm do |x|
  x.report('WithMethodDefinition') do
    1000.times { WithMethodDefinition.new(data).simple_method }
  end
  x.report('WithMethodMissing') do
    1000.times { WithMethodMissing.new(data).hello }
  end
  x.report('WithMethodMissingDefiningMethod') do
    1000.times { WithMethodMissingDefiningMethod.new(data).hello }
  end
end
