require 'json'
require 'digest'

module VideoProcessing
  module Services
    class CacheService
      def initialize(config)
        @config = config
      end
      
      def get_cache_file_path(video_filename)
        File.join(@config.cache_dir, "#{video_filename}_analysis.json")
      end
      
      def load_cache(cache_file)
        if File.exist?(cache_file)
          begin
            content = File.read(cache_file)
            JSON.parse(content)
          rescue JSON::ParserError => e
            puts "⚠️  Error parsing cache file: #{e.message}"
            []
          rescue => e
            puts "⚠️  Error reading cache file: #{e.message}"
            []
          end
        else
          []
        end
      end
      
      def save_cache(cache_file, cached_results)
        begin
          File.write(cache_file, JSON.pretty_generate(cached_results))
          puts "💾 Cache saved: #{File.basename(cache_file)}"
        rescue => e
          puts "⚠️  Error saving cache: #{e.message}"
        end
      end
      
      def has_complete_cached_analysis?(video_filename, expected_duration)
        cache_file = get_cache_file_path(video_filename)
        
        return false unless File.exist?(cache_file)
        
        cached_results = load_cache(cache_file)
        return false if cached_results.empty?
        
        # Check if we have results for all expected seconds
        cached_seconds = cached_results.map { |r| r['second'] }.sort
        expected_seconds = (1..expected_duration.to_i).to_a
        
        missing_seconds = expected_seconds - cached_seconds
        
        if missing_seconds.empty?
          puts "✅ Complete cached analysis found for #{video_filename}"
          puts "   Cached results: #{cached_results.length} seconds"
          return true
        else
          puts "⚠️  Incomplete cached analysis for #{video_filename}"
          puts "   Missing seconds: #{missing_seconds.length} (#{missing_seconds.first(5)}#{missing_seconds.length > 5 ? '...' : ''})"
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
            filename: "local_grid_second_#{cached_result['second'].to_s.rjust(3, '0')}.jpg",
            response: cached_result['response'],
            tokens_used: cached_result['tokens_used'] || 0,
            file_size_kb: 0, # Not stored in cache
            from_cache: true
          }
        end
        
        puts "📁 Loaded #{results.length} cached analysis results"
        results
      end
    end
  end
end 