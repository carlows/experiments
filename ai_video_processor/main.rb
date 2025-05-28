#!/usr/bin/env ruby

require_relative 'local_video_processing/lib/video_processor'
require_relative 'local_video_processing/lib/config'

# Main execution
if __FILE__ == $0
  local_video_file = "IMG_9009.MOV"
  
  # Initialize configuration
  config = VideoProcessing::Config.new
  
  # Check if the video file exists
  unless File.exist?(local_video_file)
    puts "❌ Video file not found: #{local_video_file}"
    puts "Please make sure the file exists in the current directory: #{Dir.pwd}"
    exit 1
  end
  
  # Check if API key is available
  unless ENV["GOOGLE_GEMINI_API_KEY"]
    puts "❌ GOOGLE_GEMINI_API_KEY environment variable not set"
    exit 1
  end
  
  # Initialize the video processor
  processor = VideoProcessing::VideoProcessor.new(config)
  
  # Get video information first
  video_info = processor.get_video_info(local_video_file)
  
  if video_info
    puts "\n📹 Processing local video: #{local_video_file}"
    puts "Expected grid images: ~#{video_info[:duration].to_i}"
  else
    puts "\n💥 Could not get video information"
    exit 1
  end
  
  # Determine video filename for caching
  video_filename = processor.determine_video_filename
  
  # Check if we have complete cached analysis
  if processor.has_complete_cached_analysis?(video_filename, video_info[:duration])
    puts "\n💾 Using complete cached analysis - skipping all processing!"
    analysis_result = processor.load_cached_analysis_as_results(video_filename)
  else
    # Check if grid images already exist
    existing_grids = processor.find_existing_grid_images
    
    if existing_grids.empty?
      puts "\n🎬 No existing grid images found. Creating them first..."
      # Process video and create 3x3 grid frames (9 FPS)
      result = processor.process_video_and_create_grid_frames(local_video_file)
      
      unless result
        puts "\n💥 Failed to process local video and create grid frames"
        exit 1
      end
      
      # Update video_filename with the new timestamp
      video_filename = processor.determine_video_filename
    else
      puts "\n🎬 Found #{existing_grids.length} existing grid images. Skipping video processing."
    end
    
    # Analyze grid images with Gemini (all images)
    analysis_result = processor.analyze_grid_images_with_gemini
  end
  
  if analysis_result
    puts "\n🎉 Analysis completed successfully!"
    puts "Check the detailed results above for per-second analysis."
    
    # Create clips based on analysis results
    clips_result = processor.create_clips_from_analysis(local_video_file, analysis_result)
    
    if clips_result && clips_result.any?
      puts "\n🎬 Video clips created successfully!"
      puts "Check the clips folder for the extracted segments."
      
      # Create combined video from all clips
      combined_result = processor.create_combined_video(clips_result, local_video_file)
      
      if combined_result
        puts "\n🎞️ Combined video created successfully!"
        puts "Combined video: #{combined_result[:filename]} (#{combined_result[:file_size_mb]} MB)"
        puts "Total clips combined: #{combined_result[:total_clips]}"
        puts "Total duration: #{combined_result[:total_duration]} seconds"
        puts "Note: Clips are concatenated without transitions for better reliability."
      else
        puts "\n⚠️ Individual clips created but failed to create combined video"
      end
    else
      puts "\n📭 No clips were created (no consecutive segments where person is visible in at least one frame)."
    end
  else
    puts "\n💥 Failed to analyze grid images with Gemini"
  end
end 