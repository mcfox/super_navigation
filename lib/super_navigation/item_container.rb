# frozen_string_literal: true

module SuperNavigation
  class ItemContainer
    attr_reader :items

    def initialize
      @items = []
    end

    def item(id, title, description = nil, icon = nil, url = nil, options = {}, &block)
      new_item = Item.new(id, title, description, icon, url, options)
      
      if block_given?
        child_container = ItemContainer.new
        child_container.instance_eval(&block)
        child_container.items.each { |child| new_item.add_child(child) }
      end

      @items << new_item
      new_item
    end

    def clear!
      @items = []
    end
  end
end
