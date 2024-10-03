require 'csv'

puts 'EventManager initialized.'

contents = File.read('event_attendees.csv')
puts contents


lines = File.readlines('event_attendees.csv')

lines.each_with_index do |line,index|
  next if index == 0
  columns = line.split(",")
  name = columns[2]
  puts name
end


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  puts "#{name} #{zipcode}"
end