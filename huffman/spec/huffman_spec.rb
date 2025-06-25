require_relative "../huffman"
require 'fileutils'

describe "Huffman" do
  context 'encode' do
    it 'generate an output file with a header that includes the prefix table' do
      root_dir = File.expand_path("..", __dir__)
      FileUtils.rm_f("#{root_dir}/output")
      output_file = "#{root_dir}/output"
      Huffman.new.encode("#{root_dir}/lesmiserables.txt", output_file)

      File.open(output_file, 'rb') do |file| 
        json_length = file.read(4).unpack('V').first
        json_bytes = file.read(json_length)
        json_table = JSON.parse(json_bytes)
        expect(json_table).to include({ "m" => "101101" })
      end
    end

    it 'stores the padding length' do
      root_dir = File.expand_path("..", __dir__)
      FileUtils.rm_f("#{root_dir}/output")
      output_file = "#{root_dir}/output"
      Huffman.new.encode("#{root_dir}/sample.txt", output_file)

      File.open(output_file, 'rb') do |file| 
        length = file.read(4).unpack('V').first # skip the json table length
        file.read(length) # skip the json table

        padding_length = file.read(1).unpack('C').first
        expect(padding_length).to eq(1)
      end
    end
  end

  context 'decode' do
    it 'decodes the encoded file' do
      root_dir = File.expand_path("..", __dir__)
      FileUtils.rm_f("#{root_dir}/output")
      output_file = "#{root_dir}/output"
      Huffman.new.encode("#{root_dir}/test_short.txt", output_file)
      table = Huffman.new.decode(output_file, "#{root_dir}/test_short_decoded.txt")

      expect(File.read("#{root_dir}/test_short_decoded.txt")).to eq("hi ")
    end
  end
end
