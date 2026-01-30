require 'forwardable'

class Item
  attr_reader :name, :last_name

  def initialize(name)
    @name = name
    @last_name = name * 2
  end
end

class WrappedItem
  extend Forwardable

  attr_reader :item

  def_delegators :item, :last_name

  def initialize(item)
    @item = item
  end

  def name
    "Wrapped: #{@item.name}"
  end
end

class List
  extend Enumerable

  def initialize(items)
    @items = items
  end

  def names
    @names ||= @items.map(&:name)
  end

  def each
    @items.each do |item| 
      yield item 
    end
  end
end

list = List.new([Item.new('hello'), Item.new('world')])
puts list.names.join(' ')
list.each do |item|
  puts item.name
end

wrapped_list = List.new([WrappedItem.new(Item.new('hello')), WrappedItem.new(Item.new('world'))])

puts wrapped_list.names.join(' ')
wrapped_list.each do |item|
  puts item.last_name
end

