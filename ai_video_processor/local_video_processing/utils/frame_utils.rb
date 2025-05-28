require 'fileutils'
require 'time'

module VideoProcessing
  module Utils
    class FrameUtils
      def initialize(config)
        @config = config
      end
      
      def cleanup_frames_folder
        puts "Cleaning up video_frames folder..."
        
        if Dir.exist?(@config.frames_dir)
          # Remove all files in the directory
          Dir.glob(File.join(@config.frames_dir, "*")).each do |file|
            File.delete(file) if File.file?(file)
          end
          puts "Cleaned up existing frames in #{@config.frames_dir}"
        else
          puts "video_frames folder doesn't exist yet"
        end
      end
      
      def extract_9fps_and_create_grids(video_file_path)
        puts "Extracting 9 frames per second and creating 3x3 grids..."
        
        # Create timestamp for unique filenames
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        
        # Create frames directory if it doesn't exist
        FileUtils.mkdir_p(@config.frames_dir)
        
        # Step 1: Extract 9 frames per second using ffmpeg
        temp_pattern = File.join(@config.frames_dir, "temp_frame_%06d.jpg")
        
        cmd = [
          'ffmpeg',
          '-i', video_file_path,
          '-vf', 'fps=9',  # Extract 9 frames per second
          '-q:v', '2',     # High quality
          '-y',            # Overwrite existing files
          temp_pattern
        ]
        
        puts "Extracting frames at 9 FPS..."
        result = system(*cmd, out: File::NULL, err: File::NULL)
        
        unless result
          puts "❌ Failed to extract frames"
          return 0
        end
        
        # Step 2: Group frames into sets of 9 and create grids
        frame_files = Dir.glob(File.join(@config.frames_dir, "temp_frame_*.jpg")).sort
        puts "Extracted #{frame_files.length} total frames"
        
        grid_count = 0
        frame_files.each_slice(9).with_index do |frame_group, index|
          if frame_group.length == 9
            second_number = index + 1
            grid_filename = "local_grid_second_#{second_number.to_s.rjust(3, '0')}_#{timestamp}.jpg"
            grid_path = File.join(@config.frames_dir, grid_filename)
            
            if create_3x3_grid(frame_group, grid_path)
              grid_count += 1
            end
          else
            puts "  Skipping incomplete group of #{frame_group.length} frames for second #{index + 1}"
          end
        end
        
        # Step 3: Clean up temporary frame files
        frame_files.each { |file| File.delete(file) if File.exist?(file) }
        
        puts "Created #{grid_count} grid images"
        grid_count
      end
      
      def create_3x3_grid(frame_files, output_path)
        puts "    Creating 3x3 grid: #{File.basename(output_path)}"
        
        # Ensure we have exactly 9 frames
        unless frame_files.length == 9
          puts "    ❌ Expected 9 frames, got #{frame_files.length}"
          return false
        end
        
        # Use ffmpeg to create a 3x3 grid
        # Create filter to arrange 9 inputs in a 3x3 grid
        filter = "[0:v][1:v][2:v]hstack=inputs=3[top];" \
                "[3:v][4:v][5:v]hstack=inputs=3[middle];" \
                "[6:v][7:v][8:v]hstack=inputs=3[bottom];" \
                "[top][middle][bottom]vstack=inputs=3[out]"
        
        cmd = ['ffmpeg']
        
        # Add all 9 input files
        frame_files.each do |frame_file|
          cmd += ['-i', frame_file]
        end
        
        cmd += [
          '-filter_complex', filter,
          '-map', '[out]',
          '-q:v', '2',  # High quality
          '-y',         # Overwrite existing files
          output_path
        ]
        
        result = system(*cmd, out: File::NULL, err: File::NULL)
        
        if result && File.exist?(output_path)
          file_size_kb = File.size(output_path) / 1024
          puts "    ✅ Grid created: #{File.basename(output_path)} (#{file_size_kb} KB)"
          return true
        else
          puts "    ❌ Failed to create grid: #{File.basename(output_path)}"
          return false
        end
      end
      
      def find_existing_grid_images
        Dir.glob(File.join(@config.frames_dir, "local_grid_second_*.jpg")).sort
      end
      
      def get_video_filename_from_grid_files(grid_files)
        # Extract video filename from grid file pattern
        # Grid files are named like: local_grid_second_001_20250528_150056.jpg
        if grid_files.any?
          first_grid = File.basename(grid_files.first)
          if match = first_grid.match(/local_grid_second_\d+_(\d{8}_\d{6})\.jpg/)
            return "local_video_#{match[1]}"
          end
        end
        
        # Fallback to current timestamp
        "local_video_#{Time.now.strftime("%Y%m%d_%H%M%S")}"
      end
    end
  end
end 