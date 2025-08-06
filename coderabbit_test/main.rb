require 'json'
require 'date'

class UserManager
  def initialize
    @users = []
    @log_file = 'user_activity.log'
  end

  # User Management
  def add_user(name, email, age)
    user = {
      id: generate_user_id,
      name: name,
      email: email,
      age: age,
      created_at: Time.now
    }
    @users << user
    log_activity("Added new user: #{name}")
    send_welcome_email(user)
    true
  end

  def delete_user(user_id)
    user = @users.find { |u| u[:id] == user_id }
    return false unless user

    @users.delete(user)
    log_activity("Deleted user: #{user[:name]}")
    send_deletion_notification(user)
    true
  end

  # Email Functionality
  def send_welcome_email(user)
    # This should be in a separate EmailService class
    puts "Sending welcome email to #{user[:email]}..."
    email_content = "Welcome #{user[:name]}! Thank you for joining."
    # Simulate email sending
    puts "Email sent: #{email_content}"
    log_activity("Sent welcome email to #{user[:email]}")
  end

  def send_deletion_notification(user)
    # This should be in a separate EmailService class
    puts "Sending deletion notification to #{user[:email]}..."
    email_content = "Goodbye #{user[:name]}. Your account has been deleted."
    # Simulate email sending
    puts "Email sent: #{email_content}"
    log_activity("Sent deletion notification to #{user[:email]}")
  end

  # Logging Functionality
  def log_activity(message)
    # This should be in a separate LoggingService class
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    log_entry = "#{timestamp} - #{message}\n"
    File.open(@log_file, 'a') { |f| f.write(log_entry) }
  end

  # Report Generation
  def generate_user_report
    # This should be in a separate ReportGenerator class
    report = {
      total_users: @users.length,
      average_age: calculate_average_age,
      user_statistics: generate_user_statistics,
      report_generated_at: Time.now
    }

    # Save report to file
    File.write('user_report.json', JSON.pretty_generate(report))
    log_activity("Generated user report")
    report
  end

  private

  def generate_user_id
    # This could be in a separate IdGenerator class
    Time.now.to_i.to_s + rand(1000..9999).to_s
  end

  def calculate_average_age
    return 0 if @users.empty?
    total_age = @users.sum { |user| user[:age] }
    total_age.to_f / @users.length
  end

  def generate_user_statistics
    # This should be in a separate StatisticsGenerator class
    {
      age_groups: calculate_age_groups,
      signup_by_month: calculate_monthly_signups
    }
  end

  def calculate_age_groups
    groups = { '0-18': 0, '19-30': 0, '31-50': 0, '51+': 0 }
    @users.each do |user|
      case user[:age]
      when 0..18 then groups[:'0-18'] += 1
      when 19..30 then groups[:'19-30'] += 1
      when 31..50 then groups[:'31-50'] += 1
      else groups[:'51+'] += 1
      end
    end
    groups
  end

  def calculate_monthly_signups
    @users.group_by { |u| u[:created_at].strftime("%Y-%m") }
          .transform_values(&:count)
  end
end

# Example usage
if __FILE__ == $0
  manager = UserManager.new
  
  # Add some users
  manager.add_user("John Doe", "john@example.com", 25)
  manager.add_user("Jane Smith", "jane@example.com", 32)
  manager.add_user("Bob Wilson", "bob@example.com", 19)
  
  # Generate a report
  report = manager.generate_user_report
  puts "\nGenerated Report:"
  puts JSON.pretty_generate(report)
  
  # Delete a user
  first_user_id = manager.instance_variable_get(:@users).first[:id]
  manager.delete_user(first_user_id)
end 