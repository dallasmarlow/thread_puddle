thread_puddle
=============

simple thread pool

```ruby
require 'thread_puddle'
puddle = ThreadPuddle.new 5 # threads

# async
puddle.submit "hello earth" do |message|
  puts message
end

# sync
puddle.perform "hello other planets" do |message|
  sleep 1
  puts message
end

puddle.shutdown
```
