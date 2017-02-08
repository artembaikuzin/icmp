module Enumerable
  ##
  # Interactively compares two sorted enumerables by key. Yields a block with
  # event (:compare, :added, :removed), current and previous enumerable items.
  #
  # ==== Parameters
  # * <tt>previous</tt> - Enumerable to compare with
  #
  # * <tt>key_proc</tt> - Proc for retrieve key value from item, sets to item
  #   by default
  #
  # ==== Example
  #
  #   # id - key element
  #   current = [{ id: 1, state: :accept },
  #              { id: 2, state: :new },
  #              { id: 4, state: :canceled }]
  #
  #   previous = [{ id: 1, state: :new },
  #               { id: 3, state: :in_progress },
  #               { id: 4, state: :canceled }]
  #
  #   # Sets proc for key retrieve
  #   current.icmp(previous, proc { |i| i[:id] }) do |event, cur_item, prev_item|
  #     print "ID: #{cur_item[:id]}, "
  #
  #     case event
  #     when :compare
  #       if cur_item[:state] != prev_item[:state]
  #         puts "new state = #{cur_item[:state]}, old state = #{prev_item[:state]}"
  #       else
  #         puts "item is not changed, state = #{cur_item[:state]}"
  #       end
  #     when :added
  #       puts "item added with state = #{cur_item[:state]}"
  #     when :removed
  #       puts "item removed with state = #{cur_item[:state]}"
  #     end
  #   end
  #
  # ===== Output
  #
  #  ID: 1, new state = accept, old state = new
  #  ID: 2, item added with state = new
  #  ID: 3, item removed with state = in_progress
  #  ID: 4, item is not changed, state = canceled
  #
  # ==== Benchmark
  #
  #   current = (1..20_000).to_a
  #   previous = current.dup
  #
  #   Benchmark.ips do |x|
  #     x.report('icmp') do
  #       current.icmp(previous) do |event, cur_item, prev_item|
  #       end
  #     end
  #
  #     x.report('binary search') do
  #       current.each do |cur_item|
  #         prev_item = previous.bsearch { |i| cur_item - i }
  #       end
  #     end
  #
  #     x.report('nested loops') do
  #       current.each do |cur_item|
  #         previous.each do |i|
  #           if cur_item == i
  #             break
  #           end
  #         end
  #       end
  #     end
  #
  #     x.compare!
  #   end
  #
  # ===== Output
  #
  #  Warming up --------------------------------------
  #                  icmp    12.000  i/100ms
  #         binary search     7.000  i/100ms
  #          nested loops     1.000  i/100ms
  #  Calculating -------------------------------------
  #                  icmp    135.101  (± 5.9%) i/s -    684.000  in   5.079674s
  #         binary search     74.424  (± 4.0%) i/s -    378.000  in   5.089745s
  #          nested loops      0.111  (± 0.0%) i/s -      1.000  in   8.970797s
  #
  #  Comparison:
  #                  icmp:      135.1 i/s
  #         binary search:       74.4 i/s - 1.82x  slower
  #          nested loops:        0.1 i/s - 1211.96x  slower
  #
  def icmp(previous, key_proc = proc { |item| item })
    raise RuntimeError.new('Block should be specified') unless block_given?

    current = self
    while current.size > 0 && previous.size > 0
      cur_item = current.first
      prev_item = previous.first

      cur_key = key_proc.call(cur_item)
      prev_key = key_proc.call(prev_item)

      if cur_key == prev_key
        yield :compare, cur_item, prev_item

        current = current.drop(1)
        previous = previous.drop(1)
      elsif cur_key < prev_key
        yield :added, cur_item

        current = current.drop(1)
      else
        yield :removed, prev_item

        previous = previous.drop(1)
      end
    end

    current.each do |item|
      yield :added, item
    end

    previous.each do |item|
      yield :removed, item
    end
  end

  alias interactive_compare icmp
end
