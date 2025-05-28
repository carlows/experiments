require 'fileutils'
require 'tempfile'
require 'langchainrb'
require 'net/http'
require 'base64'
require 'json'
require 'digest'
require 'time'

class LocalVideoProcessor
  def initialize
    @project_dir = Dir.pwd
    @frames_dir = File.join(@project_dir, 'video_frames')
    @cache_dir = File.join(@project_dir, 'analysis_cache')
    
    # Ensure cache directory exists
    FileUtils.mkdir_p(@cache_dir)
    
    # Initialize Gemini LLM
    @gemini_llm = Langchain::LLM::GoogleGemini.new(
      api_key: ENV["GOOGLE_GEMINI_API_KEY"],
      default_options: {
        chat_model: 'gemini-2.0-flash'
      }
    )
  end

  def process_local_video_and_create_grid_frames(video_file_path)
    puts "Processing local video and creating 3x3 grid frames (9 FPS): #{video_file_path}"
    
    # Check if video file exists
    unless File.exist?(video_file_path)
      puts "❌ Video file not found: #{video_file_path}"
      return nil
    end
    
    begin
      # Step 1: Clean up existing frames
      cleanup_frames_folder
      
      # Step 2: Extract 9 frames per second and create grids
      grid_count = extract_9fps_and_create_grids(video_file_path)
      
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
    unless ENV["GOOGLE_GEMINI_API_KEY"]
      puts "❌ GOOGLE_GEMINI_API_KEY environment variable not set"
      return nil
    end
    
    # Find all local grid images
    grid_files = Dir.glob(File.join(@frames_dir, "local_grid_second_*.jpg")).sort
    
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
    video_filename = get_video_filename_from_grid_files(grid_files)
    cache_file = get_cache_file_path(video_filename)
    
    # Load existing cache
    cached_results = load_cache(cache_file)
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
          file_size_kb: File.size(grid_file) / 1024,
          from_cache: true
        }
        
        total_tokens += (cached_result['tokens_used'] || 0)
        next
      end
      
      # Not in cache, call Gemini
      begin
        # Read and encode image
        image_data = File.read(grid_file)
        base64_image = Base64.strict_encode64(image_data)
        
        # Create context and prompt
        context = "You are analyzing a 3x3 grid of 9 frames extracted from one second of a skating video. Each frame shows a moment within that second."
        
        prompt = "#{context}\n\nLook at this 3x3 grid of frames from one second of video. Determine if the skating person is visible in ANY of the 9 frames of the grid. Respond with only 'yes' if the person is visible in at least one frame, or 'no' if the person is not visible in any of the frames."
        
        # Prepare messages for Gemini
        messages = [
          { 
            role: "user", 
            parts: [
              {
                inlineData: {
                  mimeType: 'image/jpeg',
                  data: base64_image,
                }
              },
              { text: prompt }
            ]
          }
        ]
        
        # Call Gemini
        puts "  🌟 Calling Gemini 2.0 Flash..."
        response = @gemini_llm.chat(messages: messages)
        api_calls_made += 1
        
        # Get the raw response data
        raw_data = response.instance_variable_get(:@raw_response)
        
        # Extract response text and clean it
        response_text = raw_data.dig("candidates", 0, "content", "parts", 0, "text")&.strip&.downcase
        
        # Extract token usage if available
        usage = raw_data.dig("usageMetadata")
 
        tokens_used = 0
        if usage
          prompt_tokens = usage["promptTokenCount"] || 0
          completion_tokens = usage["candidatesTokenCount"] || 0
          tokens_used = prompt_tokens + completion_tokens
          total_tokens += tokens_used
          puts "  Tokens used: #{tokens_used} (prompt: #{prompt_tokens}, completion: #{completion_tokens})"
        else
          puts "  ⚠️  No usage metadata found"
        end
        
        # Validate response
        if response_text == "yes" || response_text == "no"
          puts "  ✅ Response: #{response_text.upcase}"
        else
          puts "  ⚠️  Unexpected response: '#{response_text}' - treating as 'no'"
          response_text = "no"
        end
        
        # Store result
        result = {
          second: second_number,
          filename: File.basename(grid_file),
          response: response_text,
          tokens_used: tokens_used,
          file_size_kb: File.size(grid_file) / 1024,
          from_cache: false
        }
        results << result
        
        # Add to cache
        cached_results << {
          'second' => second_number,
          'response' => response_text,
          'tokens_used' => tokens_used,
          'analyzed_at' => Time.now.iso8601,
          'filename' => File.basename(grid_file)
        }
        
        # Save cache after each successful analysis
        save_cache(cache_file, cached_results)
        
        # Small delay to avoid rate limiting
        sleep(0.5)
        
      rescue => e
        puts "  ❌ Error analyzing #{File.basename(grid_file)}: #{e.message}"
        results << {
          second: second_number,
          filename: File.basename(grid_file),
          response: "error",
          tokens_used: 0,
          error: e.message,
          from_cache: false
        }
      end
    end
    
    # Summary
    puts "\n📊 Analysis Summary:"
    puts "=" * 50
    puts "Total images analyzed: #{results.length}"
    puts "API calls made: #{api_calls_made}"
    puts "Cache hits: #{cache_hits}"
    puts "Total tokens used: #{total_tokens}"
    
    yes_count = results.count { |r| r[:response] == "yes" }
    no_count = results.count { |r| r[:response] == "no" }
    error_count = results.count { |r| r[:response] == "error" }
    
    puts "Results breakdown:"
    puts "  - Person visible in at least one frame: #{yes_count} seconds"
    puts "  - Person not visible in any frames: #{no_count} seconds"
    puts "  - Errors: #{error_count} seconds"
    
    puts "\nDetailed results:"
    results.each do |result|
      status_icon = case result[:response]
                   when "yes" then "✅"
                   when "no" then "❌"
                   when "error" then "⚠️"
                   end
      cache_icon = result[:from_cache] ? "💾" : "🌟"
      puts "  Second #{result[:second]}: #{status_icon} #{result[:response].upcase} #{cache_icon} (#{result[:tokens_used]} tokens)"
    end
    
    return {
      results: results,
      total_tokens: total_tokens,
      api_calls_made: api_calls_made,
      cache_hits: cache_hits,
      summary: {
        total_analyzed: results.length,
        yes_count: yes_count,
        no_count: no_count,
        error_count: error_count
      }
    }
  end

  def create_clips_from_analysis(video_file_path, analysis_results)
    puts "\n🎬 Creating clips from analysis results..."
    
    # Create clips directory
    clips_dir = File.join(@project_dir, 'clips')
    FileUtils.mkdir_p(clips_dir)
    
    # Clean up existing clips
    cleanup_clips_folder(clips_dir)
    
    puts "Clips will be saved to: #{clips_dir}"
    
    # Extract the results array
    results = analysis_results[:results]
    
    if results.empty?
      puts "❌ No analysis results found"
      return []
    end
    
    # Find consecutive "yes" segments
    segments = find_consecutive_yes_segments(results)
    
    if segments.empty?
      puts "📭 No segments found where person is visible in at least one frame"
      return []
    end
    
    puts "Found #{segments.length} segments to extract:"
    segments.each_with_index do |segment, index|
      puts "  Segment #{index + 1}: seconds #{segment[:start]} to #{segment[:end]} (#{segment[:duration]} seconds)"
    end
    
    # Create clips for each segment
    created_clips = []
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    
    segments.each_with_index do |segment, index|
      clip_number = (index + 1).to_s.rjust(2, '0')
      clip_filename = "clip_#{clip_number}_sec#{segment[:start]}-#{segment[:end]}_#{timestamp}.mp4"
      clip_path = File.join(clips_dir, clip_filename)
      
      puts "\n🎥 Creating clip #{index + 1}/#{segments.length}: #{clip_filename}"
      
      if create_video_clip(video_file_path, segment[:start] - 1, segment[:end], clip_path)
        file_size_mb = File.size(clip_path) / 1024.0 / 1024.0
        puts "  ✅ Created: #{clip_filename} (#{file_size_mb.round(2)} MB)"
        
        created_clips << {
          filename: clip_filename,
          path: clip_path,
          start_second: segment[:start],
          end_second: segment[:end],
          duration: segment[:duration],
          file_size_mb: file_size_mb.round(2)
        }
      else
        puts "  ❌ Failed to create clip #{clip_filename}"
      end
    end
    
    # Summary
    puts "\n📊 Clip Creation Summary:"
    puts "=" * 50
    puts "Total segments found: #{segments.length}"
    puts "Clips created successfully: #{created_clips.length}"
    puts "Total duration of clips: #{created_clips.sum { |c| c[:duration] }} seconds"
    puts "Total size of clips: #{created_clips.sum { |c| c[:file_size_mb] }.round(2)} MB"
    
    if created_clips.any?
      puts "\nCreated clips:"
      created_clips.each do |clip|
        puts "  📹 #{clip[:filename]} (#{clip[:duration]}s, #{clip[:file_size_mb]}MB)"
      end
    end
    
    return created_clips
  end

  def has_complete_cached_analysis?(video_filename, expected_duration)
    cache_file = get_cache_file_path(video_filename)
    cached_results = load_cache(cache_file)
    
    if cached_results.empty?
      return false
    end
    
    # Check if we have results for all expected seconds
    expected_seconds = (1..expected_duration.to_i).to_a
    cached_seconds = cached_results.map { |r| r['second'] }.sort
    
    missing_seconds = expected_seconds - cached_seconds
    
    if missing_seconds.empty?
      puts "✅ Found complete cached analysis for all #{expected_duration.to_i} seconds"
      return true
    else
      puts "⚠️  Cached analysis incomplete. Missing seconds: #{missing_seconds.first(5).join(', ')}#{missing_seconds.length > 5 ? '...' : ''}"
      return false
    end
  end

  def load_cached_analysis_as_results(video_filename)
    cache_file = get_cache_file_path(video_filename)
    cached_results = load_cache(cache_file)
    
    # Convert cached format to results format
    results = cached_results.map do |cached_result|
      {
        second: cached_result['second'],
        filename: cached_result['filename'] || "cached_second_#{cached_result['second']}",
        response: cached_result['response'],
        tokens_used: cached_result['tokens_used'] || 0,
        file_size_kb: 0, # Not relevant for cached results
        from_cache: true
      }
    end.sort_by { |r| r[:second] }
    
    # Calculate summary
    total_tokens = results.sum { |r| r[:tokens_used] }
    yes_count = results.count { |r| r[:response] == "yes" }
    no_count = results.count { |r| r[:response] == "no" }
    error_count = results.count { |r| r[:response] == "error" }
    
    puts "\n📊 Loaded Cached Analysis Summary:"
    puts "=" * 50
    puts "Total images analyzed: #{results.length}"
    puts "API calls made: 0 (all from cache)"
    puts "Cache hits: #{results.length}"
    puts "Total tokens used: #{total_tokens}"
    
    puts "Results breakdown:"
    puts "  - Person visible in at least one frame: #{yes_count} seconds"
    puts "  - Person not visible in any frames: #{no_count} seconds"
    puts "  - Errors: #{error_count} seconds"
    
    puts "\nDetailed results:"
    results.each do |result|
      status_icon = case result[:response]
                   when "yes" then "✅"
                   when "no" then "❌"
                   when "error" then "⚠️"
                   end
      puts "  Second #{result[:second]}: #{status_icon} #{result[:response].upcase} 💾 (#{result[:tokens_used]} tokens)"
    end
    
    return {
      results: results,
      total_tokens: total_tokens,
      api_calls_made: 0,
      cache_hits: results.length,
      summary: {
        total_analyzed: results.length,
        yes_count: yes_count,
        no_count: no_count,
        error_count: error_count
      }
    }
  end

  def create_combined_video(created_clips, video_file_path)
    puts "\n🎞️ Creating combined video from all clips with fade transitions..."
    
    if created_clips.empty?
      puts "❌ No clips to combine"
      return nil
    end
    
    # Create output directory
    output_dir = File.join(@project_dir, 'output')
    FileUtils.mkdir_p(output_dir)
    
    # Clean up existing output videos
    cleanup_output_folder(output_dir)
    
    puts "Combined video will be saved to: #{output_dir}"
    
    # Generate timestamp and output filename
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    base_name = File.basename(video_file_path, File.extname(video_file_path))
    output_filename = "#{base_name}_combined_#{timestamp}.mp4"
    output_path = File.join(output_dir, output_filename)
    
    puts "Combining #{created_clips.length} clips into: #{output_filename}"
    puts "Total duration: #{created_clips.sum { |c| c[:duration] }} seconds"
    
    if created_clips.length == 1
      # If only one clip, just copy it
      puts "Only one clip found, copying without transitions..."
      cmd = [
        'ffmpeg',
        '-i', created_clips.first[:path],
        '-c', 'copy',
        '-y',
        output_path
      ]
    else
      # Multiple clips - use xfade transitions
      fade_duration = 1.0  # 1 second fade between clips
      puts "Adding #{fade_duration}s fade transitions between clips..."
      
      cmd = build_xfade_command(created_clips, output_path, fade_duration)
    end
    
    puts "Running ffmpeg with xfade transitions..."
    
    result = system(*cmd, out: File::NULL, err: File::NULL)
    
    if result && File.exist?(output_path) && File.size(output_path) > 0
      file_size_mb = File.size(output_path) / 1024.0 / 1024.0
      puts "✅ Combined video created: #{output_filename} (#{file_size_mb.round(2)} MB)"
      
      return {
        filename: output_filename,
        path: output_path,
        file_size_mb: file_size_mb.round(2),
        total_clips: created_clips.length,
        total_duration: created_clips.sum { |c| c[:duration] }
      }
    else
      puts "❌ Failed to create combined video"
      return nil
    end
  end

  def build_xfade_command(clips, output_path, fade_duration)
    # Build complex ffmpeg command with xfade filter
    cmd = ['ffmpeg']
    
    # Add all input files
    clips.each do |clip|
      cmd += ['-i', clip[:path]]
    end
    
    # Build filter complex for xfade transitions
    video_filters = []
    audio_filters = []
    current_video_output = "[0:v]"
    
    # Calculate cumulative durations for xfade timing
    cumulative_duration = 0
    
    clips.each_with_index do |clip, index|
      if index > 0
        # Calculate when to start the fade (fade_duration before the end of accumulated content)
        fade_start = cumulative_duration - fade_duration
        fade_start = [fade_start, 0].max  # Ensure it's not negative
        
        next_video_output = index == clips.length - 1 ? "[outv]" : "[v#{index}]"
        
        # Add xfade filter for video
        video_filters << "#{current_video_output}[#{index}:v]xfade=transition=fade:duration=#{fade_duration}:offset=#{fade_start}#{next_video_output}"
        
        current_video_output = next_video_output
      end
      
      # Add this clip's duration (minus fade overlap for subsequent clips)
      if index == 0
        cumulative_duration += clip[:duration]
      else
        cumulative_duration += clip[:duration] - fade_duration
      end
    end
    
    # Build complete filter complex with both video and audio
    if video_filters.any?
      # For audio, we need to concatenate (not mix) the audio streams
      # Create audio concat filter
      audio_inputs = clips.each_with_index.map { |_, i| "[#{i}:a]" }.join('')
      audio_filter = "#{audio_inputs}concat=n=#{clips.length}:v=0:a=1[outa]"
      
      # Combine video and audio filters
      complete_filter = "#{video_filters.join(';')};#{audio_filter}"
      
      cmd += ['-filter_complex', complete_filter]
      cmd += ['-map', '[outv]', '-map', '[outa]']
    end
    
    cmd += ['-c:v', 'libx264', '-c:a', 'aac', '-preset', 'fast', '-crf', '23', '-y', output_path]
    
    return cmd
  end

  def cleanup_output_folder(output_dir)
    puts "Cleaning up output folder..."
    
    if Dir.exist?(output_dir)
      # Remove all files in the directory
      Dir.glob(File.join(output_dir, "*")).each do |file|
        File.delete(file) if File.file?(file)
      end
      puts "Cleaned up existing output videos in #{output_dir}"
    else
      puts "output folder doesn't exist yet"
    end
  end

  private

  def extract_9fps_and_create_grids(video_file_path)
    puts "Extracting 9 frames per second and creating 3x3 grids..."
    
    # Ensure video_frames directory exists
    FileUtils.mkdir_p(@frames_dir)
    puts "Grid images will be saved to: #{@frames_dir}"
    
    # Create temporary directory for individual frames
    temp_frames_dir = Dir.mktmpdir('temp_frames_9fps_local_')
    
    # Generate timestamp for unique filenames
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    
    begin
      # Step 1: Extract 9 frames per second
      puts "Extracting 9 frames per second from local video..."
      output_pattern = File.join(temp_frames_dir, "frame_%06d.jpg")
      
      cmd = [
        'ffmpeg',
        '-i', video_file_path,
        '-vf', 'fps=9',  # Extract 9 frames per second
        '-q:v', '2',     # High quality
        '-y',            # Overwrite output files
        output_pattern
      ]
      
      puts "Running: #{cmd.join(' ')}"
      result = system(*cmd, out: File::NULL, err: File::NULL)
      
      unless result
        raise "ffmpeg frame extraction failed"
      end
      
      # Step 2: Get all extracted frames
      all_frames = Dir.glob(File.join(temp_frames_dir, "frame_*.jpg")).sort
      puts "Total frames extracted: #{all_frames.length}"
      
      if all_frames.empty?
        raise "No frames were extracted"
      end
      
      # Step 3: Group frames by second and create grids
      grid_count = 0
      current_second = 1
      
      # Process frames in groups of 9
      all_frames.each_slice(9).with_index do |frame_group, index|
        if frame_group.length == 9
          grid_filename = "local_grid_second_#{current_second.to_s.rjust(3, '0')}_#{timestamp}.jpg"
          grid_path = File.join(@frames_dir, grid_filename)
          
          if create_3x3_grid(frame_group, grid_path)
            grid_count += 1
            puts "  Created grid #{current_second}: #{grid_filename} (#{File.size(grid_path) / 1024} KB)"
          else
            puts "  ❌ Failed to create grid for second #{current_second}"
          end
          
          current_second += 1
        else
          puts "  Skipping incomplete group with #{frame_group.length} frames (second #{current_second})"
        end
      end
      
      puts "Successfully created #{grid_count} grid images"
      return grid_count
      
    ensure
      # Clean up temporary frames
      FileUtils.rm_rf(temp_frames_dir) if Dir.exist?(temp_frames_dir)
    end
  end

  def create_3x3_grid(frame_files, output_path)
    puts "    Creating 3x3 grid: #{File.basename(output_path)}"
    
    # Resize each frame to 170x170 first (512/3 ≈ 170 with some padding)
    resized_frames = []
    
    frame_files.each_with_index do |frame_file, index|
      resized_frame = File.join(File.dirname(frame_file), "resized_#{index}.jpg")
      
      # Resize frame to 170x170 with padding
      cmd = [
        'ffmpeg',
        '-i', frame_file,
        '-vf', 'scale=170:170:force_original_aspect_ratio=decrease,pad=170:170:(ow-iw)/2:(oh-ih)/2:black',
        '-q:v', '2',
        '-y',
        resized_frame
      ]
      
      result = system(*cmd, out: File::NULL, err: File::NULL)
      
      if result && File.exist?(resized_frame)
        resized_frames << resized_frame
      else
        puts "    ❌ Failed to resize frame #{index + 1}"
        return false
      end
    end
    
    # Create 3x3 grid using ffmpeg
    cmd = [
      'ffmpeg',
      '-i', resized_frames[0], '-i', resized_frames[1], '-i', resized_frames[2],
      '-i', resized_frames[3], '-i', resized_frames[4], '-i', resized_frames[5],
      '-i', resized_frames[6], '-i', resized_frames[7], '-i', resized_frames[8],
      '-filter_complex',
      '[0:v][1:v][2:v]hstack=inputs=3[top];[3:v][4:v][5:v]hstack=inputs=3[middle];[6:v][7:v][8:v]hstack=inputs=3[bottom];[top][middle][bottom]vstack=inputs=3[grid]',
      '-map', '[grid]',
      '-q:v', '2',
      '-y',
      output_path
    ]
    
    result = system(*cmd, out: File::NULL, err: File::NULL)
    
    # Clean up resized frames
    resized_frames.each { |f| File.delete(f) if File.exist?(f) }
    
    return result && File.exist?(output_path)
  end

  def cleanup_frames_folder
    puts "Cleaning up video_frames folder..."
    
    if Dir.exist?(@frames_dir)
      # Remove all files in the directory
      Dir.glob(File.join(@frames_dir, "*")).each do |file|
        File.delete(file) if File.file?(file)
      end
      puts "Cleaned up existing frames in #{@frames_dir}"
    else
      puts "video_frames folder doesn't exist yet"
    end
  end

  def get_video_info(video_file_path)
    puts "Getting video information..."
    
    cmd = [
      'ffprobe',
      '-v', 'quiet',
      '-print_format', 'json',
      '-show_format',
      '-show_streams',
      video_file_path
    ]
    
    result = `#{cmd.join(' ')}`
    
    if $?.success?
      require 'json'
      info = JSON.parse(result)
      
      video_stream = info['streams'].find { |s| s['codec_type'] == 'video' }
      
      if video_stream
        duration = info['format']['duration'].to_f
        width = video_stream['width']
        height = video_stream['height']
        fps = eval(video_stream['r_frame_rate']) if video_stream['r_frame_rate']
        
        puts "Video info:"
        puts "  Duration: #{duration.round(2)} seconds"
        puts "  Resolution: #{width}x#{height}"
        puts "  FPS: #{fps.round(2)}" if fps
        puts "  File size: #{File.size(video_file_path) / 1024 / 1024} MB"
        
        return {
          duration: duration,
          width: width,
          height: height,
          fps: fps,
          file_size_mb: File.size(video_file_path) / 1024 / 1024
        }
      end
    end
    
    puts "Could not get video information"
    return nil
  end

  def get_video_filename_from_grid_files(grid_files)
    # Extract video filename from grid file pattern
    # Grid files are named like: local_grid_second_001_20250528_150056.jpg
    if grid_files.any?
      first_file = File.basename(grid_files.first)
      # Extract timestamp part to identify the video session
      if match = first_file.match(/local_grid_second_\d+_(\d{8}_\d{6})\.jpg/)
        return "local_video_#{match[1]}"
      end
    end
    
    # Fallback to a generic name
    "local_video_unknown"
  end

  def get_cache_file_path(video_filename)
    File.join(@cache_dir, "#{video_filename}_analysis.json")
  end

  def load_cache(cache_file)
    if File.exist?(cache_file)
      begin
        content = File.read(cache_file)
        JSON.parse(content)
      rescue JSON::ParserError => e
        puts "⚠️  Warning: Could not parse cache file #{File.basename(cache_file)}: #{e.message}"
        []
      end
    else
      []
    end
  end

  def save_cache(cache_file, cached_results)
    begin
      File.write(cache_file, JSON.pretty_generate(cached_results))
      puts "  💾 Cache updated: #{File.basename(cache_file)}"
    rescue => e
      puts "  ⚠️  Warning: Could not save cache: #{e.message}"
    end
  end

  def find_consecutive_yes_segments(results)
    segments = []
    current_segment_start = nil
    
    # Sort results by second to ensure proper order
    sorted_results = results.sort_by { |r| r[:second] }
    
    sorted_results.each do |result|
      if result[:response] == "yes"
        # Start a new segment if we're not in one
        current_segment_start = result[:second] if current_segment_start.nil?
      else
        # End current segment if we were in one
        if current_segment_start
          end_second = sorted_results.select { |r| r[:second] < result[:second] && r[:response] == "yes" }.last[:second]
          duration = end_second - current_segment_start + 1
          
          # Only add segments that are 5 seconds or longer
          if duration >= 5
            segments << {
              start: current_segment_start,
              end: end_second,
              duration: duration
            }
          else
            puts "  Skipping short segment: seconds #{current_segment_start}-#{end_second} (#{duration}s < 5s minimum)"
          end
          
          current_segment_start = nil
        end
      end
    end
    
    # Handle case where video ends with a "yes" segment
    if current_segment_start
      last_yes_second = sorted_results.select { |r| r[:response] == "yes" }.last[:second]
      duration = last_yes_second - current_segment_start + 1
      
      # Only add segments that are 5 seconds or longer
      if duration >= 5
        segments << {
          start: current_segment_start,
          end: last_yes_second,
          duration: duration
        }
      else
        puts "  Skipping short final segment: seconds #{current_segment_start}-#{last_yes_second} (#{duration}s < 5s minimum)"
      end
    end
    
    segments
  end

  def create_video_clip(input_video_path, start_second, end_second, output_path)
    # Calculate duration
    duration = end_second - start_second
    
    # Use ffmpeg to extract the clip with proper keyframe handling
    cmd = [
      'ffmpeg',
      '-ss', start_second.to_s,        # Seek to start time first (input seeking)
      '-i', input_video_path,
      '-t', duration.to_s,             # Duration in seconds
      '-c:v', 'libx264',               # Re-encode video to avoid keyframe issues
      '-c:a', 'aac',                   # Re-encode audio
      '-preset', 'fast',               # Fast encoding preset
      '-crf', '23',                    # Good quality
      '-avoid_negative_ts', 'make_zero', # Handle timestamp issues
      '-y',                            # Overwrite output file
      output_path
    ]
    
    puts "    Running: ffmpeg -ss #{start_second} -i #{File.basename(input_video_path)} -t #{duration} -c:v libx264 -c:a aac #{File.basename(output_path)}"
    
    result = system(*cmd, out: File::NULL, err: File::NULL)
    
    return result && File.exist?(output_path) && File.size(output_path) > 0
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
end

# Main execution
if __FILE__ == $0
  local_video_file = "IMG_9009.MOV"
  
  processor = LocalVideoProcessor.new
  
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
  
  # Get video information first
  video_info = processor.send(:get_video_info, local_video_file)
  
  if video_info
    puts "\n📹 Processing local video: #{local_video_file}"
    puts "Expected grid images: ~#{video_info[:duration].to_i}"
  end
  
  # Check if we have complete cached analysis
  video_filename = "local_video_#{Time.now.strftime("%Y%m%d_%H%M%S")}" # This will be updated below
  if video_info
    # Try to find existing cache by looking for grid files or cache files
    existing_grids = Dir.glob(File.join(processor.instance_variable_get(:@frames_dir), "local_grid_second_*.jpg"))
    if existing_grids.any?
      # Extract timestamp from existing grid files
      first_grid = File.basename(existing_grids.first)
      if match = first_grid.match(/local_grid_second_\d+_(\d{8}_\d{6})\.jpg/)
        video_filename = "local_video_#{match[1]}"
      end
    end
    
    if processor.has_complete_cached_analysis?(video_filename, video_info[:duration])
      puts "\n💾 Using complete cached analysis - skipping all processing!"
      analysis_result = processor.load_cached_analysis_as_results(video_filename)
    else
      # Check if grid images already exist
      if existing_grids.empty?
        puts "\n🎬 No existing grid images found. Creating them first..."
        # Process video and create 3x3 grid frames (9 FPS)
        result = processor.process_local_video_and_create_grid_frames(local_video_file)
        
        unless result
          puts "\n💥 Failed to process local video and create grid frames"
          exit 1
        end
        
        # Update video_filename with the new timestamp
        new_grids = Dir.glob(File.join(processor.instance_variable_get(:@frames_dir), "local_grid_second_*.jpg"))
        if new_grids.any?
          first_grid = File.basename(new_grids.first)
          if match = first_grid.match(/local_grid_second_\d+_(\d{8}_\d{6})\.jpg/)
            video_filename = "local_video_#{match[1]}"
          end
        end
      else
        puts "\n🎬 Found #{existing_grids.length} existing grid images. Skipping video processing."
      end
      
      # Analyze grid images with Gemini (all images)
      analysis_result = processor.analyze_grid_images_with_gemini
    end
  else
    puts "\n💥 Could not get video information"
    exit 1
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