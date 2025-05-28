require 'fileutils'

module VideoProcessing
  class Config
    attr_reader :project_dir, :frames_dir, :cache_dir, :clips_dir, :output_dir
    
    def initialize
      @project_dir = Dir.pwd
      @frames_dir = File.join(@project_dir, 'video_frames')
      @cache_dir = File.join(@project_dir, 'analysis_cache')
      @clips_dir = File.join(@project_dir, 'clips')
      @output_dir = File.join(@project_dir, 'output')
      
      # Ensure directories exist
      ensure_directories_exist
    end
    
    def gemini_api_key
      ENV["GOOGLE_GEMINI_API_KEY"]
    end
    
    def gemini_model
      'gemini-2.0-flash'
    end
    
    def minimum_segment_duration
      5 # seconds
    end
    
    def fade_duration
      0.5 # seconds for video transitions
    end
    
    def ffmpeg_preset
      'fast'
    end
    
    def video_quality_crf
      23
    end
    
    private
    
    def ensure_directories_exist
      [@frames_dir, @cache_dir, @clips_dir, @output_dir].each do |dir|
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end
    end
  end
end 