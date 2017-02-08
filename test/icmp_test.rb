require 'minitest/autorun'
require 'icmp'

class IcmpTest < MiniTest::Test
  def setup
    @key_proc = proc { |item| item[:id] }
  end

  def test_raise_runtime_error
    assert_raises(RuntimeError) { Icmp.compare(nil, nil) }
  end

  def test_set_default_key_proc
    current = [1, 2]
    previous = [1, 2]

    Icmp.compare(current, previous) do |event, current, previous|
      assert_equal(:compare, event)
      assert_equal(current, previous)
    end
  end

  def test_equals_arrays
    current = [{ id: 1 }, { id: 2 }, { id: 3 }]
    previous = [{ id: 1 }, { id: 2 }, { id: 3 }]

    Icmp.compare(current, previous, @key_proc) do |event, current, previous|
      assert_equal(:compare, event)
      assert_equal(current, previous)
    end
  end

  def test_added_elements
    current = [{ id: 0 }, { id: 1 }, { id: 1.5 }, { id: 2 }, { id: 5 }]
    previous = [{ id: 1 }, { id: 2 }]

    expect = [:added, { :id => 0 }, nil, :compare, { :id => 1 }, { :id => 1 },
              :added, { :id => 1.5 }, nil, :compare, { :id => 2 }, { :id => 2 },
              :added, { :id => 5 }, nil]
    actual = []

    Icmp.compare(current, previous, @key_proc) do |event, current, previous|
      actual << event
      actual << current
      actual << previous
    end

    assert_equal(expect, actual)
  end

  def test_removed_elements
    current = [{ id: 1 }, { id: 2 }]
    previous = [{ id: 0 }, { id: 1 }, { id: 1.5 }, { id: 2 }, { id: 5 }]

    expect = [:removed, { :id => 0 }, nil, :compare, { :id => 1 }, { :id => 1 },
              :removed, { :id => 1.5 }, nil, :compare, { :id => 2 },
              { :id => 2 }, :removed, { :id => 5 }, nil]
    actual = []

    Icmp.compare(current, previous, @key_proc) do |event, current, previous|
      actual << event
      actual << current
      actual << previous
    end

    assert_equal(expect, actual)
  end

  def test_both
    current = [{ id: -1 }, { id: 1 }, { id: 1.8 }, { id: 2 }, { id: 4 }]
    previous = [{ id: 0 }, { id: 1 }, { id: 1.5 }, { id: 2 }, { id: 5 }]

    expect = [:added, { :id => -1 }, nil, :removed, { :id => 0 }, nil, :compare,
              { :id => 1 }, { :id => 1 }, :removed, { :id => 1.5 }, nil, :added,
              { :id => 1.8 }, nil, :compare, { :id => 2 }, { :id => 2 }, :added,
              { :id => 4 }, nil, :removed, { :id => 5 }, nil]
    actual = []

    Icmp.compare(current, previous, @key_proc) do |event, current, previous|
      actual << event
      actual << current
      actual << previous
    end

    assert_equal(expect, actual)
  end

  def test_empty_arrays
    expected = []
    actual = []

    Icmp.compare([], [], @key_proc) do |event, current, previous|
      actual << event
      actual << current
      actual << previous
    end

    assert_equal(0, expected.size)
    assert_equal(0, actual.size)
  end
end
