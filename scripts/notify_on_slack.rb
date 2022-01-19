#!/usr/bin/env ruby

require 'json'

message= ARGV[0]
slack_webhook = ARGV[1]

if message == ""
  puts "Message is required"
  exit(1)
end

if slack_webhook == ""
  puts "Slack webhook is required"
  exit(1)
end

# Remove single quote to avoid errors in the curl cmd.
clean_message = message.gsub('\'', "")

final_message="<!here> #{clean_message}"
data_json= {
  "text" => final_message
}.to_json()

cmd = "curl -X POST --data-urlencode 'payload=#{data_json}' #{slack_webhook}"
system(cmd)
