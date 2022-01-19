#!/usr/bin/env ruby

require "uri"
require "net/http"

pr_description = ARGV[0]
monday_api_key = ARGV[1]
message = ARGV[2]

if pr_description == ""
  puts "Pull Request description is required"
  exit(1)
end

if monday_api_key == ""
  puts "Monday API key is required"
  exit(1)
end

if message == ""
  puts "Message is required"
  exit(1)
end

lines = pr_description.split('\n')

monday_url = lines[0]
url_components = monday_url.split("/")

is_next_board_id = false
is_next_item_id = false
board_id = -1
item_id = -1

url_components.each do |component|
  if is_next_board_id
    is_next_board_id = false
    board_id = component
  end

  if is_next_item_id
    is_next_item_id = false
    # Remove url params and extra comments from the line
    item_id = component.split(' ')[0].split('?')[0]
  end

  if component == "boards"
    is_next_board_id = true
  end

  if component == "pulses"
    is_next_item_id = true
  end

  if board_id != -1 && item_id != -1
    # Only the first url in the description will be used
    break
  end
end

if board_id == -1 || item_id == -1
  puts "ERROR: Pull request's description must contain a valid monday.com pulse url in the first line."
  exit(1)
end

query="mutation {create_update (item_id: #{item_id}, body: \"#{message}\") { id }}"

url = URI("https://api.monday.com/v2/")

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Authorization"] = monday_api_key
form_data = [['query', query]]
request.set_form form_data, 'multipart/form-data'
response = https.request(request)
