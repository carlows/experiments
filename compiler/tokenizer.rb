# frozen_string_literal: true

class Token
  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def ==(other)
    type == other.type && value == other.value
  end
end

class Tokenizer
  attr_reader :input

  def initialize(input)
    @input = input
    @current = 0
    @char = input[@current]
    @tokens = []
  end

  def tokenize
    while @current < input.length
      @char = input[@current]

      case @char
      when '('
        handle_open_paren
      when ')'
        handle_close_paren
      when /\s/
        handle_whitespace
      when /[0-9]/
        handle_number
      when '"'
        handle_string
      when /[a-z]/
        handle_name
      else
        raise "I don't know what this character is: #{@char}"
      end
    end

    @tokens
  end

  private

  def handle_open_paren
    @tokens.push(Token.new('paren', '('))
    @current += 1
    @char = input[@current]
  end

  def handle_close_paren
    @tokens.push(Token.new('paren', ')'))
    @current += 1
    @char = input[@current]
  end

  def handle_whitespace
    @current += 1
    @char = input[@current]
  end

  def handle_number
    value = ''

    while @char.match(/[0-9]/)
      value += @char
      @char = input[@current + 1]
      @current += 1
    end

    @tokens.push(Token.new('number', value))
  end

  def handle_string
    value = ''
    @char = input[@current += 1]

    while @char != '"'
      value += @char
      @char = input[@current += 1]
    end

    # skips the closing quote
    @current += 1

    @tokens.push(Token.new('string', value))
  end

  def handle_name
    value = ''

    while @char.match(/[a-z]/)
      value += @char
      @char = input[@current += 1]
    end

    @tokens.push(Token.new('name', value))
  end
end