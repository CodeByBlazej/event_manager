require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'



contents = File.read('event_attendees.csv')
puts contents


lines = File.readlines('event_attendees.csv')
lines.each_with_index do |line,index|
  next if index == 0
  columns = line.split(",")
  name = columns[2]
  puts name
end


puts 'EventManager initialized.'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')
end

def clean_homePhone(homePhone)
  cleared_number = homePhone.delete('^0-9')

  return 'We are sorry, the number you provided seems to be wrong...' if cleared_number.size < 10
  cleared_number.size > 10 && cleared_number.start_with?('1') ? cleared_number[1..10] : cleared_number
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

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  homePhone = clean_homePhone(row[:homephone])
  regdate = row[:regdate]
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  p regdate.split(' ')[1]
  # puts Time.parse(regdate)
end