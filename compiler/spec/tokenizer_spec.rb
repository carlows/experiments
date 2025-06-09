require_relative '../tokenizer'

RSpec.describe Tokenizer do
  describe '#tokenize' do
    it 'returns an array of tokens' do
      tokenizer = Tokenizer.new('(add 2 (subtract 4 2))')
      expect(tokenizer.tokenize).to eq([
        Token.new('paren', '('),
        Token.new('name', 'add'),
        Token.new('number', '2'),
        Token.new('paren', '('),
        Token.new('name', 'subtract'),
        Token.new('number', '4'),
        Token.new('number', '2'),
        Token.new('paren', ')'),
        Token.new('paren', ')')
      ])
    end
  end
end 