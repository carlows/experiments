require_relative '../prefix_codes'
require_relative '../huffman_tree'

RSpec.describe PrefixCodes do
  let(:frequencies) { { 'C' => 32, 'D' => 42, 'E' => 120, 'K' => 7, 'L' => 42, 'M' => 24, 'U' => 37, 'Z' => 2 } }
  let(:tree) { HuffmanTree.build_tree(frequencies) }
  let(:prefix_codes) { PrefixCodes.new(tree) }

  context 'generate_table' do
    it 'should generate a table of prefix codes' do
      table = prefix_codes.generate_table
      expect(table).to eq({
        'C' => '1110',
        'D' => '101',
        'E' => '0',
        'K' => '111101',
        'L' => '110',
        'M' => '11111',
        'U' => '100',
        'Z' => '111100'
      })
    end
  end
end