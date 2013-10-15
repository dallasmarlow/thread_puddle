thread_puddle
=============

simple thread pool

```ruby
require 'thread_puddle'
puddle = ThreadPuddle.new 5 # threads

puddle.submit "hello world" do |message|
  puts message
end

puddle.shutdown
```
