require_relative "../huffman"

describe "Huffman" do
  context 'encode' do
    it 'should return the character count' do
      root_dir = File.expand_path("..", __dir__)
      expect(Huffman.new.encode("#{root_dir}/lesmiserables.txt"))
        .to include({ 'm' => '101101', 'o' => '0110' })
    end 
  end
end