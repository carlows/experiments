require 'json'

module VideoProcessing
  module Utils
    class VideoUtils
      def initialize(config)
        @config = config
      end
      
      def get_video_info(video_file_path)
        puts "Getting video information..."
        
        # Use ffprobe to get video information
        cmd = [
          'ffprobe',
          '-v', 'quiet',
          '-print_format', 'json',
          '-show_format',
          '-show_streams',
          video_file_path
        ]
        
        begin
          output = `#{cmd.join(' ')}`
          
          if $?.success?
            data = JSON.parse(output)
            
            # Find video stream
            video_stream = data['streams'].find { |s| s['codec_type'] == 'video' }
            
            if video_stream
              duration = data['format']['duration'].to_f
              width = video_stream['width']
              height = video_stream['height']
              fps = eval(video_stream['r_frame_rate']) # e.g., "30/1" -> 30.0
              
              info = {
                duration: duration,
                width: width,
                height: height,
                fps: fps,
                size_mb: File.size(video_file_path) / (1024.0 * 1024.0)
              }
              
              puts "✅ Video info: #{duration.round(1)}s, #{width}x#{height}, #{fps.round(1)} FPS, #{info[:size_mb].round(1)} MB"
              return info
            else
              puts "❌ No video stream found"
              return nil
            end
          else
            puts "❌ ffprobe failed"
            return nil
          end
        rescue JSON::ParserError => e
          puts "❌ Error parsing ffprobe output: #{e.message}"
          return nil
        rescue => e
          puts "❌ Error getting video info: #{e.message}"
          return nil
        end
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
          '-preset', @config.ffmpeg_preset, # Fast encoding preset
          '-crf', @config.video_quality_crf.to_s, # Good quality
          '-avoid_negative_ts', 'make_zero', # Handle timestamp issues
          '-y',                            # Overwrite output file
          output_path
        ]
        
        puts "    Running: ffmpeg -ss #{start_second} -i #{File.basename(input_video_path)} -t #{duration} -c:v libx264 -c:a aac #{File.basename(output_path)}"
        
        result = system(*cmd, out: File::NULL, err: File::NULL)
        
        return result && File.exist?(output_path) && File.size(output_path) > 0
      end
      
      def build_xfade_command(clips, output_path, fade_duration)
        # Build simple ffmpeg command for concatenating clips without transitions
        cmd = ['ffmpeg']
        
        # Add all input files
        clips.each do |clip|
          cmd += ['-i', clip[:path]]
        end
        
        if clips.length == 1
          # Single clip, no concatenation needed
          cmd += [
            '-c:v', 'libx264',
            '-c:a', 'aac',
            '-preset', @config.ffmpeg_preset,
            '-crf', @config.video_quality_crf.to_s,
            '-y',
            output_path
          ]
        else
          # Multiple clips - simple concatenation without transitions
          filter_complex = build_simple_concat_filter(clips)
          
          cmd += [
            '-filter_complex', filter_complex,
            '-map', '[outv]',
            '-map', '[outa]',
            '-c:v', 'libx264',
            '-c:a', 'aac',
            '-preset', @config.ffmpeg_preset,
            '-crf', @config.video_quality_crf.to_s,
            '-y',
            output_path
          ]
        end
        
        cmd
      end
      
      private
      
      def build_simple_concat_filter(clips)
        # Simple concatenation filter - no crossfades, just join clips together
        puts "DEBUG: Building simple concatenation for #{clips.length} clips"
        
        # Build video concatenation
        video_inputs = clips.map.with_index { |_, i| "[#{i}:v]" }.join('')
        video_filter = "#{video_inputs}concat=n=#{clips.length}:v=1:a=0[outv]"
        
        # Build audio concatenation  
        audio_inputs = clips.map.with_index { |_, i| "[#{i}:a]" }.join('')
        audio_filter = "#{audio_inputs}concat=n=#{clips.length}:v=0:a=1[outa]"
        
        filter_complex = "#{video_filter};#{audio_filter}"
        puts "DEBUG: Simple concat filter: #{filter_complex}"
        
        return filter_complex
      end
    end
  end
end 