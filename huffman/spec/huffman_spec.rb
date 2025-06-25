require_relative "../huffman"

describe "Huffman" do
  context 'encode' do
    it 'should return the character count' do
      root_dir = File.expand_path("..", __dir__)
      expect(Huffman.new.encode("#{root_dir}/lesmiserables.txt"))
        .to include({ 'X' => 331, 't' => 221545 })
    end 
  end
end