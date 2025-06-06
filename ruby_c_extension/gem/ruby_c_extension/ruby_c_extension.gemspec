# frozen_string_literal: true

require_relative "lib/ruby_c_extension/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_c_extension"
  spec.version = RubyCExtension::VERSION
  spec.authors = ["Carlos Martinez"]
  spec.email = ["carlos.martinez@medwing.com"]

  spec.summary = "A Ruby gem with C extensions"
  spec.description = "A Ruby gem that demonstrates how to create and use C extensions"
  spec.homepage = "https://github.com/example/ruby_c_extension"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/example/ruby_c_extension"
  spec.metadata["changelog_uri"] = "https://github.com/example/ruby_c_extension/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/ruby_c_extension/extconf.rb"]

  # Development dependencies
  spec.add_development_dependency "rake-compiler", "~> 1.0"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
