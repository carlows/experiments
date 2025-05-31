# frozen_string_literal: true

require_relative "ruby_c_extension/version"
require_relative "ruby_c_extension/fibonacci"

module RubyCExtension
  module Fibonacci
    def self.nth_fibonacci(n)
      ::Extension::Fibonacci.nth_fibonacci(n)
    end
  end
end
