# frozen_string_literal: true

class ASTNode
  attr_accessor :type, :value, :params
  def initialize(type, value, params = [])
    @type = type
    @value = value
    @params = params
  end

  def ==(other)
    @type == other.type && @value == other.value && @params == other.params
  end
end

class Parser
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    ast = ASTNode.new('Program', nil)

    while @current < @tokens.length
      ast.params.push(walk)
    end

    ast
  end

  def walk
    token = @tokens[@current]

    if token.type == 'number'
      @current += 1
      return ASTNode.new('NumberLiteral', token.value)
    end
    
    if token.type == 'string'
      @current += 1
      return ASTNode.new('StringLiteral', token.value)
    end
    
    if token.type == 'paren' && token.value == '('
      token = @tokens[@current += 1]
      node = ASTNode.new('CallExpression', token.value)

      token = @tokens[@current += 1]

      while token.type != 'paren' || (token.type == 'paren' && token.value != ')')
        node.params.push(walk)
        token = @tokens[@current]
      end

      @current += 1

      return node
    end

    raise "I don't know what this token is: #{token.inspect}"
  end
end
