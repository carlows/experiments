# KATA 3: THE MEGA MIDDLEWARE CHAIN
# ---------------------------------
# Goal: Build a professional-grade instrumentation and middleware system using AOP.
#
# Instructions:
# Fill in the TODOs in the modules and classes below.
# Run the file to see which stages you pass.

# 1. Timing: Measure how long the call takes and store in env[:duration]
module TimingMiddleware
  def call(env)
    start_time = Time.now
    res = super
    env[:duration] = Time.now - start_time
    res
  end
end

# 2. Auth: Add :user => "admin" to env before passing down
module AuthMiddleware
  def call(env)
    env[:user] = "admin"
    super(env)
  end
end

# 3. Payload: If the result is "OK", transform it to "SUCCESS"
module PayloadMiddleware
  def call(env)
    res = super
    return "SUCCESS" if res == "OK"
    res
  end
end

# 4. Recovery: Rescue StandardError and return "FAIL SAFE"
module RecoveryMiddleware
  def call(env)
    super
  rescue StandardError
    "FAIL SAFE"
  end
end

# 5. Cache: If env[:cached_result] exists, return it immediately (skip super)
module CacheMiddleware
  def call(env)
    return env[:cached_result] if env.key?(:cached_result)
    super
  end
end

# 6. Singleton Surge: Implement this method to prepend a module to ONLY 
# the given object's singleton class.
def apply_singleton_middleware(object, mod)
  object.singleton_class.prepend(mod)
end

# Core Application
class App
  def call(env)
    raise "Triggered Error" if env[:error]
    env[:status] = 200
    "OK"
  end

  # 7. Signature: Handle complex signatures
  def execute(id, name: nil, **options)
    "Executed #{id} for #{name}"
  end

  private

  def internal_log(msg)
    "LOG: #{msg}"
  end
end

# 7. Argument Forwarder: Correctly forward (id, name: nil, **options)
module SignatureMiddleware
  def execute(...)
    super(...)
  end
end

# 8. Dynamic Stack: Builder to apply multiple middlewares
class StackBuilder
  def self.apply(klass, middlewares)
  # A, B
  # B, A, Mod
    middlewares.each { |m| klass.prepend(m) }
  end
end

# 9. Privacy Breach: Access private method 'internal_log'
module LoggingMiddleware
  def call(env)
    env[:log] = internal_log("intercepted")
    super
    # TODO: Call 'internal_log("intercepted")' and store in env[:log]
    # then call super
  end
end

# --- TEST SUITE (DO NOT MODIFY) ---
@stages_passed = 0
def verify_stage(name)
  yield
  puts "✅ #{name} Passed"
  @stages_passed += 1
rescue => e
  puts "❌ #{name} Failed: #{e.message}"
end

puts "Starting 10-Stage Verification..."

# Stage 1: Basic Wrap
verify_stage("Stage 1 (Timing)") do
  App.prepend(TimingMiddleware)
  env = {}
  App.new.call(env)
  raise "Duration not set" unless env.key?(:duration)
end

# Stage 2: Environment Injection
verify_stage("Stage 2 (Auth)") do
  App.prepend(AuthMiddleware)
  env = {}
  App.new.call(env)
  raise "User not set" unless env[:user] == "admin"
end

# Stage 3: Post-processor
verify_stage("Stage 3 (Payload)") do
  App.prepend(PayloadMiddleware)
  res = App.new.call({})
  raise "Result not transformed" unless res == "SUCCESS"
end

# Stage 4: Safety Net
verify_stage("Stage 4 (Recovery)") do
  App.prepend(RecoveryMiddleware)
  res = App.new.call({error: true})
  raise "Error not caught" unless res == "FAIL SAFE"
end

# Stage 5: Short-circuit
verify_stage("Stage 5 (Cache)") do
  App.prepend(CacheMiddleware)
  res = App.new.call({cached_result: "FROM CACHE"})
  raise "Cache not used" unless res == "FROM CACHE"
end

# Stage 6: Singleton Surge
verify_stage("Stage 6 (Singleton)") do
  module DebugMod; def call(env); env[:debug] = true; super; end; end
  app1 = App.new
  app2 = App.new
  apply_singleton_middleware(app1, DebugMod)
  
  env1, env2 = {}, {}
  app1.call(env1)
  app2.call(env2)
  raise "Debug leaked to app2" if env2.key?(:debug)
  raise "Debug missing from app1" unless env1[:debug]
  raise "DebugMod should not be in App ancestors" if App.ancestors.include?(DebugMod)
end

# Stage 7: Signature Master
verify_stage("Stage 7 (Signatures)") do
  App.prepend(SignatureMiddleware)
  res = App.new.execute(1, name: "Test")
  raise "Signature mismatch" unless res == "Executed 1 for Test"
end

# Stage 8: Auto-Stacker
verify_stage("Stage 8 (Stacker)") do
  module ModA; def call(env); env[:stack] << "A"; super; end; end
  module ModB; def call(env); env[:stack] << "B"; super; end; end
  class MockApp; def call(env); "OK"; end; end
  
  StackBuilder.apply(MockApp, [ModA, ModB])
  env = {stack: []}
  MockApp.new.call(env)
  puts env[:stack].inspect
  raise "Stack order incorrect #{env[:stack].inspect}" unless env[:stack] == ["B", "A"]
end

# Stage 9: Hidden Access
verify_stage("Stage 9 (Privacy)") do
  App.prepend(LoggingMiddleware)
  env = {}
  App.new.call(env)
  raise "Private method not called" unless env[:log] == "LOG: intercepted"
end

# Stage 10: Final Order check
verify_stage("Stage 10 (Chain integrity)") do
  chain = App.ancestors.take_while { |a| a != Object }
  # Check if our modules are actually in the chain
  raise "Chain corrupted" unless chain.include?(TimingMiddleware) && chain.include?(App)
end

if @stages_passed == 10
  puts "
🏆 ALL STAGES COMPLETE! You are a Middleware Master."
else
  puts "
❌ You passed #{@stages_passed}/10 stages. Keep going!"
  exit 1
end
