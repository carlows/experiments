require 'fileutils'
require 'tempfile'
require 'time'

require_relative '../services/cache_service'
require_relative '../services/gemini_service'
require_relative '../utils/video_utils'
require_relative '../utils/frame_utils'
require_relative '../utils/file_utils'

module VideoProcessing
  class VideoProcessor
    def initialize(config)
      @config = config
      @cache_service = Services::CacheService.new(config)
      @gemini_service = Services::GeminiService.new(config)
      @video_utils = Utils::VideoUtils.new(config)
      @frame_utils = Utils::FrameUtils.new(config)
      @file_utils = Utils::FileUtils.new(config)
    end
    
    def process_video_and_create_grid_frames(video_file_path)
      puts "Processing local video and creating 3x3 grid frames (9 FPS): #{video_file_path}"
      
      # Check if video file exists
      unless File.exist?(video_file_path)
        puts "❌ Video file not found: #{video_file_path}"
        return nil
      end
      
      begin
        # Step 1: Clean up existing frames
        @frame_utils.cleanup_frames_folder
        
        # Step 2: Extract 9 frames per second and create grids
        grid_count = @frame_utils.extract_9fps_and_create_grids(video_file_path)
        
        puts "✅ Successfully created #{grid_count} grid images (9 frames per second)"
        return grid_count
        
      rescue => e
        puts "❌ Error processing video and creating grids: #{e.message}"
        puts e.backtrace.first(5)
        return nil
      end
    end
    
    def analyze_grid_images_with_gemini(limit = nil)
      puts "\n🤖 Starting Gemini 2.0 Flash analysis of grid images..."
      if limit
        puts "Analyzing first #{limit} grid images"
      else
        puts "Analyzing all grid images"
      end
      
      # Check if API key is available
      unless @config.gemini_api_key
        puts "❌ GOOGLE_GEMINI_API_KEY environment variable not set"
        return nil
      end
      
      # Find all local grid images
      grid_files = @frame_utils.find_existing_grid_images
      
      if grid_files.empty?
        puts "❌ No grid images found. Please run the video processing first."
        return nil
      end
      
      puts "Found #{grid_files.length} grid images total"
      
      # Limit to first N images for testing
      grid_files = grid_files.first(limit) if limit
      if limit
        puts "Processing first #{grid_files.length} images"
      else
        puts "Processing all #{grid_files.length} images"
      end
      
      # Get video filename for cache key
      video_filename = @frame_utils.get_video_filename_from_grid_files(grid_files)
      cache_file = @cache_service.get_cache_file_path(video_filename)
      
      # Load existing cache
      cached_results = @cache_service.load_cache(cache_file)
      puts "📁 Cache file: #{File.basename(cache_file)}"
      puts "📁 Found #{cached_results.length} cached results" if cached_results.any?
      
      results = []
      total_tokens = 0
      api_calls_made = 0
      cache_hits = 0
      
      grid_files.each_with_index do |grid_file, index|
        second_number = index + 1
        puts "\n📸 Analyzing second #{second_number}: #{File.basename(grid_file)}"
        
        # Check cache first
        cached_result = cached_results.find { |r| r['second'] == second_number }
        
        if cached_result
          puts "  💾 Using cached result: #{cached_result['response'].upcase}"
          cache_hits += 1
          
          # Convert cached result to our format
          results << {
            second: second_number,
            filename: File.basename(grid_file),
            response: cached_result['response'],
            tokens_used: cached_result['tokens_used'] || 0,
            file_size_kb: @file_utils.get_file_size_kb(grid_file),
            from_cache: true
          }
          
          total_tokens += (cached_result['tokens_used'] || 0)
          next
        end
        
        # Not in cache, call Gemini
        begin
          gemini_result = @gemini_service.analyze_grid_image(grid_file)
          api_calls_made += 1
          
          total_tokens += gemini_result[:tokens_used]
          
          # Store result
          result = {
            second: second_number,
            filename: File.basename(grid_file),
            response: gemini_result[:response],
            tokens_used: gemini_result[:tokens_used],
            file_size_kb: @file_utils.get_file_size_kb(grid_file),
            from_cache: false
          }
          results << result
          
          # Add to cache
          cached_results << {
            'second' => second_number,
            'response' => gemini_result[:response],
            'tokens_used' => gemini_result[:tokens_used],
            'timestamp' => Time.now.iso8601
          }
          
          # Save cache after each API call
          @cache_service.save_cache(cache_file, cached_results)
          
        rescue => e
          puts "  ❌ Error analyzing image: #{e.message}"
          # Add a default "no" result for failed analysis
          results << {
            second: second_number,
            filename: File.basename(grid_file),
            response: "no",
            tokens_used: 0,
            file_size_kb: @file_utils.get_file_size_kb(grid_file),
            from_cache: false,
            error: e.message
          }
        end
      end
      
      # Print summary
      puts "\n📊 Analysis Summary:"
      puts "   Total images analyzed: #{results.length}"
      puts "   API calls made: #{api_calls_made}"
      puts "   Cache hits: #{cache_hits}"
      puts "   Total tokens used: #{total_tokens}"
      
      yes_count = results.count { |r| r[:response] == "yes" }
      no_count = results.count { |r| r[:response] == "no" }
      puts "   Results: #{yes_count} YES, #{no_count} NO"
      
      results
    end
    
    def create_clips_from_analysis(video_file_path, analysis_results)
      puts "\n🎬 Creating clips from analysis results..."
      
      # Find consecutive "yes" segments
      segments = find_consecutive_yes_segments(analysis_results)
      
      if segments.empty?
        puts "❌ No consecutive segments found where person is visible"
        return []
      end
      
      puts "Found #{segments.length} segments to extract:"
      segments.each_with_index do |segment, index|
        analysis_start = segment[:start] + 1
        analysis_end = segment[:end]
        puts "  Segment #{index + 1}: video time #{segment[:start]}s-#{segment[:end]}s (#{segment[:duration]}s) [analysis seconds #{analysis_start}-#{analysis_end}]"
      end
      
      # Clean up clips folder
      @file_utils.cleanup_clips_folder(@config.clips_dir)
      @file_utils.ensure_directory_exists(@config.clips_dir)
      
      # Create clips
      created_clips = []
      segments.each_with_index do |segment, index|
        clip_number = index + 1
        clip_filename = "clip_#{clip_number.to_s.rjust(2, '0')}_#{segment[:start]}s-#{segment[:end]}s.mp4"
        clip_path = File.join(@config.clips_dir, clip_filename)
        
        puts "\n🎥 Creating clip #{clip_number}: #{clip_filename}"
        puts "   Extracting video time #{segment[:start]}s to #{segment[:end]}s (#{segment[:duration]}s duration)"
        
        success = @video_utils.create_video_clip(video_file_path, segment[:start], segment[:end], clip_path)
        
        if success
          file_size_mb = @file_utils.get_file_size_mb(clip_path)
          puts "   ✅ Clip created: #{clip_filename} (#{file_size_mb.round(1)} MB)"
          
          created_clips << {
            number: clip_number,
            filename: clip_filename,
            path: clip_path,
            start_second: segment[:start],
            end_second: segment[:end],
            duration: segment[:duration],
            file_size_mb: file_size_mb
          }
        else
          puts "   ❌ Failed to create clip: #{clip_filename}"
        end
      end
      
      puts "\n✅ Created #{created_clips.length} clips successfully"
      created_clips
    end
    
    def create_combined_video(created_clips, video_file_path)
      puts "\n🎞️ Creating combined video from all clips (simple concatenation)..."
      
      return nil if created_clips.empty?
      
      # Clean up output folder
      @file_utils.cleanup_output_folder(@config.output_dir)
      @file_utils.ensure_directory_exists(@config.output_dir)
      
      # Create output filename
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      base_name = File.basename(video_file_path, File.extname(video_file_path))
      output_filename = "#{base_name}_combined_#{timestamp}.mp4"
      output_path = File.join(@config.output_dir, output_filename)
      
      puts "Output file: #{output_filename}"
      puts "Combining #{created_clips.length} clips without transitions..."
      
      # Build ffmpeg command (fade_duration parameter is ignored now)
      cmd = @video_utils.build_xfade_command(created_clips, output_path, @config.fade_duration)
      
      puts "Running ffmpeg command..."
      puts "DEBUG: FFmpeg command: #{cmd.join(' ')}"
      result = system(*cmd, out: File::NULL, err: File::NULL)
      
      if result && File.exist?(output_path) && File.size(output_path) > 0
        file_size_mb = @file_utils.get_file_size_mb(output_path)
        total_duration = created_clips.sum { |clip| clip[:duration] }
        
        puts "✅ Combined video created successfully!"
        
        return {
          filename: output_filename,
          path: output_path,
          file_size_mb: file_size_mb.round(1),
          total_clips: created_clips.length,
          total_duration: total_duration
        }
      else
        puts "❌ Failed to create combined video"
        return nil
      end
    end
    
    def get_video_info(video_file_path)
      @video_utils.get_video_info(video_file_path)
    end
    
    def find_existing_grid_images
      @frame_utils.find_existing_grid_images
    end
    
    def determine_video_filename
      existing_grids = find_existing_grid_images
      @frame_utils.get_video_filename_from_grid_files(existing_grids)
    end
    
    def has_complete_cached_analysis?(video_filename, expected_duration)
      @cache_service.has_complete_cached_analysis?(video_filename, expected_duration)
    end
    
    def load_cached_analysis_as_results(video_filename)
      @cache_service.load_cached_analysis_as_results(video_filename)
    end
    
    private
    
    def find_consecutive_yes_segments(results)
      segments = []
      current_segment_start = nil
      
      # Sort results by second to ensure proper order
      sorted_results = results.sort_by { |r| r[:second] }
      
      sorted_results.each do |result|
        if result[:response] == "yes"
          # Start a new segment if we're not in one
          # Convert analysis second to video timestamp: second N covers time (N-1) to N
          video_start_time = result[:second] - 1
          current_segment_start = video_start_time if current_segment_start.nil?
        else
          # End current segment if we were in one
          if current_segment_start
            # Find the last "yes" result before this "no" result
            last_yes_result = sorted_results.select { |r| r[:second] < result[:second] && r[:response] == "yes" }.last
            if last_yes_result
              # Convert analysis second to video end time: second N covers time (N-1) to N
              video_end_time = last_yes_result[:second]  # End at second N (not N-1)
              duration = video_end_time - current_segment_start
              
              # Only add segments that meet minimum duration requirement
              if duration >= @config.minimum_segment_duration
                segments << {
                  start: current_segment_start,
                  end: video_end_time,
                  duration: duration
                }
                puts "  Found segment: video time #{current_segment_start}s-#{video_end_time}s (analysis seconds #{current_segment_start + 1}-#{last_yes_result[:second]})"
              else
                puts "  Skipping short segment: video time #{current_segment_start}s-#{video_end_time}s (#{duration}s < #{@config.minimum_segment_duration}s minimum)"
              end
            end
            
            current_segment_start = nil
          end
        end
      end
      
      # Handle case where video ends with a "yes" segment
      if current_segment_start
        last_yes_result = sorted_results.select { |r| r[:response] == "yes" }.last
        if last_yes_result
          # Convert analysis second to video end time
          video_end_time = last_yes_result[:second]
          duration = video_end_time - current_segment_start
          
          # Only add segments that meet minimum duration requirement
          if duration >= @config.minimum_segment_duration
            segments << {
              start: current_segment_start,
              end: video_end_time,
              duration: duration
            }
            puts "  Found final segment: video time #{current_segment_start}s-#{video_end_time}s (analysis seconds #{current_segment_start + 1}-#{last_yes_result[:second]})"
          else
            puts "  Skipping short final segment: video time #{current_segment_start}s-#{video_end_time}s (#{duration}s < #{@config.minimum_segment_duration}s minimum)"
          end
        end
      end
      
      segments
    end
  end
end 