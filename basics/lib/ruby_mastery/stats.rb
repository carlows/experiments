require 'json'
require 'date'

module RubyMastery
  class Stats
    STATS_FILE = File.join(Dir.home, '.ruby_mastery_stats.json')

    def self.log_completion(challenge_name)
      stats = load_stats
      date = Date.today.to_s

      stats[:completions] ||= {}
      stats[:completions][date] ||= []
      stats[:completions][date] << challenge_name unless stats[:completions][date].include?(challenge_name)

      save_stats(stats)
    end

    def self.display
      stats = load_stats
      completions = stats[:completions] || {}

      puts "\n--- Mastery Profile ---".colorize(:magenta).bold

      # Simple streak calculation
      streak = calculate_streak(completions)
      puts "Current Streak: #{streak} days".colorize(:yellow)
      puts "Total Katas Completed: #{completions.values.flatten.uniq.size}".colorize(:cyan)

      puts "\nActivity Graph:".colorize(:white)
      display_graph(completions)
    end

    private

    def self.load_stats
      if File.exist?(STATS_FILE)
        JSON.parse(File.read(STATS_FILE), symbolize_names: true)
      else
        { completions: {} }
      end
    end

    def self.save_stats(stats)
      File.write(STATS_FILE, JSON.pretty_generate(stats))
    end

    def self.calculate_streak(completions)
      streak = 0
      date = Date.today
      while completions[date.to_s]
        streak += 1
        date -= 1
      end
      streak
    end

    def self.display_graph(completions)
      # Display last 10 weeks
      end_date = Date.today
      start_date = end_date - (10 * 7)

      days = %w[Sun Mon Tue Wed Thu Fri Sat]
      print '      '
      (0..9).each { |w| print "W#{w} " }
      puts ''

      (0..6).each do |day_idx|
        print "#{days[day_idx]} ".colorize(:gray)
        (0..9).each do |week_idx|
          date = start_date + (week_idx * 7) + day_idx
          count = completions[date.to_s]&.size || 0
          char = case count
                 when 0 then '▢ '
                 when 1..2 then '▤ '.colorize(:green)
                 else '▣ '.colorize(:green).bold
                 end
          print char
        end
        puts ''
      end
      puts "\n(▢: 0, ▤: 1-2, ▣: 3+ katas)".colorize(:gray)
    end
  end
end
