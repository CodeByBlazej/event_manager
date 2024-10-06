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


contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  puts form_letter
end