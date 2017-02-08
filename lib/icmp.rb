module Icmp
  ##
  # Interactively compares two sorted enumerables by key. Yields a block with
  # event (:compare, :added, :removed), current and previous enumerable items.
  #
  # ==== Parameters
  # * <tt>current</tt> - Array with current values
  # * <tt>previous</tt> - Array to compare with, previous values
  # * <tt>key_proc</tt> - Proc for retrieve key value from item. Sets to item
  #   by default
  #
  # ==== Example
  #   require 'icmp'
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
  #   Icmp.compare(current, previous, proc { |i| i[:id] }) do |event, cur_item, prev_item|
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
  def self.compare(current, previous, key_proc = proc { |item| item })
    raise RuntimeError.new('Block should be specified') unless block_given?

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
end
