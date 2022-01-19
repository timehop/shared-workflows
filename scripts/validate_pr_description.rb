#!/usr/bin/env ruby

if ARGV.length != 1
    puts "Missing pull request description argument"
    exit 0
end

pr_description = ARGV[0]

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

exit(0)
