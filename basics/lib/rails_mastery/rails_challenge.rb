require 'active_record'
require 'pg'
require 'colorize'
require 'fileutils'
require 'database_cleaner/active_record'

module RailsMastery
  class RailsChallenge
    attr_reader :name, :file_path, :db_name

    def initialize(name, file_name)
      @name = name
      @file_path = File.join(Dir.pwd, 'playground', 'rails', file_name)
      @db_name = "rails_mastery_#{file_name.gsub('.rb', '')}"
    end

    def setup_database
      # Connect to default postgres to create/drop the test database
      begin
        conn = PG.connect(dbname: 'postgres')
        conn.exec("DROP DATABASE IF EXISTS #{@db_name}")
        conn.exec("CREATE DATABASE #{@db_name}")
        conn.close
      rescue PG::Error => e
        puts "Error connecting to Postgres: #{e.message}".colorize(:red)
        puts 'Make sure Postgres is running on localhost:5432'.colorize(:yellow)
        exit 1
      end

      # Connect ActiveRecord to the new database
      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        database: @db_name,
        host: 'localhost'
      )
    end

    def setup
      setup_database
      define_schema
      seed_data
      write_kata_file
    end

    def define_schema
      raise NotImplementedError
    end

    def seed_data
      # Optional override
    end

    def write_kata_file
      raise NotImplementedError
    end

    def debrief
      puts "\n--- Sensei's Note ---".colorize(:blue).bold
    end

    def verify
      unless File.exist?(@file_path)
        puts 'File not found! Run setup first.'.colorize(:red)
        return false
      end

      # Run the file with the database name passed as an environment variable
      output = `DB_NAME=#{@db_name} ruby #{@file_path} 2>&1`
      success = $?.success?

      if success
        puts '✨ Excellent work! The Rails kata is complete.'.colorize(:green).bold
        debrief
        true
      else
        puts '❌ Not quite there yet. Rails reported an error:'.colorize(:red)
        puts '-' * 40
        puts output.colorize(:light_black)
        puts '-' * 40
        false
      end
    end

    protected

    def write_file(content)
      # Prepend the DB connection boilerplate so the kata file is standalone
      boilerplate = <<~RUBY
        require 'active_record'
        require 'pg'

        ActiveRecord::Base.establish_connection(
          adapter: 'postgresql',
          database: ENV['DB_NAME'],
          host: 'localhost'
        )

        # Silence logger for cleaner output, but you can enable it for debugging
        # ActiveRecord::Base.logger = Logger.new(STDOUT)
      RUBY

      FileUtils.mkdir_p(File.dirname(@file_path))
      File.write(@file_path, boilerplate + "\n" + content)
      puts "Rails Kata generated at: #{@file_path.colorize(:cyan)}"
    end
  end
end
