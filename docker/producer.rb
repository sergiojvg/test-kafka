#!/usr/bin/ruby2.7

require 'rdkafka'
require 'date'

puts "Launching producer.rb script"

input_topic = "input"

config = { "bootstrap.servers": "kafka-headless:9092" }

producer = Rdkafka::Config.new(config).producer

while true do
  puts "Sending timestamp: #{DateTime.now.strftime('%s')} to input"
  producer.produce(topic: input_topic, payload: DateTime.now.strftime('%s'))
  sleep 10
end

