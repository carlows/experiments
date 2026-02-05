require 'active_record'
require 'pg'
require 'colorize'
require 'fileutils'
require_relative 'stats'

module RailsMastery
  class RailsChallenge
    attr_reader :name, :file_path, :db_name

    def initialize(name, file_name)
      @name = name
      @file_path = File.join(Dir.pwd, 'playground', 'rails', file_name)
      @db_name = "rails_mastery_#{file_name.gsub('.rb', '')}"
    end

    def setup_database
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

      ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        database: @db_name,
        host: 'localhost'
      )
    end

    def reset_db
      setup_database
      define_schema
      seed_data
    end

    def setup
      reset_db
      write_kata_file
    end

    def define_schema
      raise NotImplementedError
    end

    def seed_data
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

      # 1. Reset the database state before every verification
      reset_db

      # 2. Run the file
      output = `DB_NAME=#{@db_name} ruby #{@file_path} 2>&1`
      success = $?.success?

      if success
        puts '✨ Excellent work! The Rails kata is complete.'.colorize(:green).bold
        RubyMastery::Stats.log_completion(@name)
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
      boilerplate = <<~RUBY
        require 'active_record'
        require 'pg'

        ActiveRecord::Base.establish_connection(
          adapter: 'postgresql',
          database: ENV['DB_NAME'],
          host: 'localhost'
        )
      RUBY

      FileUtils.mkdir_p(File.dirname(@file_path))
      File.write(@file_path, boilerplate + "\n" + content)
      puts "Rails Kata generated at: #{@file_path.colorize(:cyan)}"
    end
  end
end
