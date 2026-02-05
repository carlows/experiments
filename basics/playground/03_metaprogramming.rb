def __; :blank; end
# REQUIREMENT:
# Create a class called 'SecretVault' that allows setting and getting 
# ANY attribute dynamically. 
# 
# vault = SecretVault.new
# vault.any_name = "some value"
# vault.any_name # => "some value"
#
# DO NOT use attr_accessor. Use metaprogramming.

class SecretVault
  def initialize
    @data = {}
  end

  def method_missing(name, *args)
    if name.to_s.end_with?('=')
      @data[name.to_s.chomp('=').to_sym] = args.first
    else
      @data[name.to_sym]
    end
  end
end

# --- TEST SUITE ---
vault = SecretVault.new

begin
  vault.password = "1234"
  if vault.password == "1234"
    puts "✅ password handled"
  else
    raise "Value mismatch"
  end

  vault.username = "admin"
  if vault.username == "admin"
    puts "✅ username handled"
  else
    raise "Value mismatch"
  end
  
  puts "✨ Metaprogramming Level Cleared!"
rescue NoMethodError => e
  puts "❌ Missing method: #{e.message}"
  exit 1
rescue => e
  puts "❌ Error: #{e.message}"
  exit 1
end
