require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'


contents = File.read('event_attendees.csv')
puts contents


lines = File.readlines('event_attendees.csv')
lines.each_with_index do |line,index|
  next if index == 0
  columns = line.split(",")
  name = columns[2]
  puts name
end

# PROPER ASSIGNMENT STARTS HERE
puts 'EventManager initialized.'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')
end

def clean_homePhone(homePhone)
  cleared_number = homePhone.delete('^0-9')

  return 'We are sorry, the number you provided seems to be wrong...' if cleared_number.size < 10
  cleared_number.size > 10 && cleared_number.start_with?('1') ? cleared_number[1..10] : cleared_number
end


def get_hours(regdate, all_hours)
  hour = DateTime.strptime(regdate, '%m/%d/%y %H:%M').hour
  all_hours << hour
end

def get_days(regdate, all_days)
  day = DateTime.strptime(regdate, '%m/%d/%y %H:%M').wday
  all_days << day
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('secret.key').strip

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
all_hours = []
all_days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  homePhone = clean_homePhone(row[:homephone])
  hours = get_hours(row[:regdate], all_hours)
  day = get_days(row[:regdate], all_days)
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
end

peak_hours = all_hours.tally.sort_by { |hour, count| -count }

peak_hours.each do |hour, count|
  puts "Hour: #{hour} Times: #{count}"
end

peak_days = all_days.tally.sort_by { |day, count| -count }

peak_days.each do |day, count|
  day_names = Date::DAYNAMES

  puts "Day: #{day_names[day]}, Times: #{count}"
end