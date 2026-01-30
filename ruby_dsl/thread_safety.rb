class Counts
  attr_reader :counters

  def initialize
    @counters = Hash.new(0)
    @mutex = Mutex.new
  end

  def [](key)
    @counters[key]
  end

  def increment(key)
    @mutex.synchronize do
      value = @counters[key]
      sleep 0.00001
      @counters[key] = value + 1
    end
  end
end

counts = Counts.new

threads = 1000.times.map do |i|
  Thread.new do
    counts.increment(:a) 
  end
end

threads.each(&:join)

puts counts[:a]
