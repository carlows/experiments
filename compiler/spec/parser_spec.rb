require_relative '../parser'
require_relative '../tokenizer'

describe Parser do
  describe '#parse' do
    it 'parses a number' do
      parser = Parser.new([Token.new('number', '1')])
      expect(parser.parse).to eq(ASTNode.new('Program', nil, [ASTNode.new('NumberLiteral', '1')]))
    end

    it 'parses a string' do
      parser = Parser.new([Token.new('string', 'hello')])
      expect(parser.parse).to eq(ASTNode.new('Program', nil, [ASTNode.new('StringLiteral', 'hello')]))
    end

    it 'parses a call expression' do
      parser = Parser.new([Token.new('paren', '('), Token.new('name', 'add'), Token.new('number', '2'), Token.new('number', '2'), Token.new('paren', ')')])
      expect(parser.parse).to eq(ASTNode.new('Program', nil, [ASTNode.new('CallExpression', 'add', [ASTNode.new('NumberLiteral', '2'), ASTNode.new('NumberLiteral', '2')])]))
    end
  end
end