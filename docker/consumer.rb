#!/usr/bin/ruby2.7

require 'rdkafka'
require 'date'

puts "Launching consumer.rb script"

input_topic = "input"
output_topic = "output"

config = { "bootstrap.servers": "kafka-headless:9092",
  }

config = {
  "bootstrap.servers": "kafka-headless:9092",
  "group.id": "sergio-test"
}

consumer = Rdkafka::Config.new(config).consumer
producer = Rdkafka::Config.new(config).producer

consumer.subscribe(input_topic)

consumer.each do |message|
  puts "Message received: #{message}"
  puts "Message received: #{message.methods}"
  time = Time.at(message.payload.to_i)
  producer.produce(topic: output_topic, payload: time.utc.strftime('%FT%TZ'))
end



