require 'fileutils'

module VideoProcessing
  module Utils
    class FileUtils
      def initialize(config)
        @config = config
      end
      
      def cleanup_output_folder(output_dir)
        puts "Cleaning up output folder..."
        
        if Dir.exist?(output_dir)
          # Remove all files in the directory
          Dir.glob(File.join(output_dir, "*")).each do |file|
            File.delete(file) if File.file?(file)
          end
          puts "Cleaned up existing files in #{output_dir}"
        else
          puts "Output folder doesn't exist yet"
        end
      end
      
      def cleanup_clips_folder(clips_dir)
        puts "Cleaning up clips folder..."
        
        if Dir.exist?(clips_dir)
          # Remove all files in the directory
          Dir.glob(File.join(clips_dir, "*")).each do |file|
            File.delete(file) if File.file?(file)
          end
          puts "Cleaned up existing clips in #{clips_dir}"
        else
          puts "clips folder doesn't exist yet"
        end
      end
      
      def ensure_directory_exists(directory)
        ::FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
      end
      
      def get_file_size_mb(file_path)
        return 0 unless File.exist?(file_path)
        File.size(file_path) / (1024.0 * 1024.0)
      end
      
      def get_file_size_kb(file_path)
        return 0 unless File.exist?(file_path)
        File.size(file_path) / 1024
      end
    end
  end
end 