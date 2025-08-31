module SuperDuperAssertions
  def assert(msg, actual, expected)
    if actual != expected
      puts "#{msg}: woops expected: #{expected} actual: #{actual}" 
      return
    end

    puts "#{msg}: success!"
  end
end
