require 'icmp'
require 'benchmark/ips'

current = (1..20_000).to_a
previous = current.dup

Benchmark.ips do |x|
  x.report('interactive_compare') do
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
