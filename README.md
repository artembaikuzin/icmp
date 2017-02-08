# Ruby extension for interactive comparison of two Enumerables

This gem adds method `icmp(previous, ...)` to ruby module `Enumerable` for interactive comparing of two sorted enumerables. Method takes O(n) time to process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'icmp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install icmp

## Usage

```ruby
require 'icmp'

# id - key element
current = [{ id: 1, state: :accept },
           { id: 2, state: :new },
           { id: 4, state: :canceled }]
           
previous = [{ id: 1, state: :new },
            { id: 3, state: :in_progress },
            { id: 4, state: :canceled }]
            
# Sets proc for key retrieve
current.icmp(previous, proc { |i| i[:id] }) do |event, cur_item, prev_item|
  print "ID: #{cur_item[:id]}, "
  #
  case event
  when :compare
    if cur_item[:state] != prev_item[:state]
      puts "new state = #{cur_item[:state]}, old state = #{prev_item[:state]}"
    else
      puts "item is not changed, state = #{cur_item[:state]}"
    end
  when :added
    puts "item added with state = #{cur_item[:state]}"
  when :removed
    puts "item removed with state = #{cur_item[:state]}"
  end
end
```

#### Output
```
ID: 1, new state = accept, old state = new
ID: 2, item added with state = new
ID: 3, item removed with state = in_progress
ID: 4, item is not changed, state = canceled
```

## Benchmark
```ruby
current = (1..20_000).to_a
previous = current.dup

Benchmark.ips do |x|
  x.report('icmp') do
    current.icmp(previous) do |event, cur_item, prev_item|
    end
  end

  x.report('binary search') do
    current.each do |cur_item|
      prev_item = previous.bsearch { |i| cur_item - i }
    end
  end

  x.report('nested loops') do
    current.each do |cur_item|
      previous.each do |i|
        if cur_item == i
          break
        end
      end
    end
  end

  x.compare!
end
```

#### Output
```
Warming up --------------------------------------
                icmp    12.000  i/100ms
       binary search     7.000  i/100ms
        nested loops     1.000  i/100ms
Calculating -------------------------------------
                icmp    135.101  (± 5.9%) i/s -    684.000  in   5.079674s
       binary search     74.424  (± 4.0%) i/s -    378.000  in   5.089745s
        nested loops      0.111  (± 0.0%) i/s -      1.000  in   8.970797s

Comparison:
                icmp:      135.1 i/s
       binary search:       74.4 i/s - 1.82x  slower
        nested loops:        0.1 i/s - 1211.96x  slower
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ybinzu/icmp.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

