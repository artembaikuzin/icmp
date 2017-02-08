require 'benchmark/ips'
require_relative '../lib/icmp'

current = (1..20_000).to_a
previous = current.dup

Benchmark.ips do |x|
  x.report('interactive_compare') do
      Icmp.compare(current, previous) do |event, cur_item, prev_item|
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
