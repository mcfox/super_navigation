# frozen_string_literal: true

module SuperNavigation
  class Item
    attr_accessor :id, :title, :description, :icon, :url, :children, :options

    def initialize(id, title, description = nil, icon = nil, url = nil, options = {})
      @id = id.to_s
      @title = title
      @description = description
      @icon = icon
      @url = url
      @children = []
      @options = options
    end

    def add_child(child_item)
      @children << child_item
    end

    def has_children?
      !@children.empty?
    end

    def to_hash
      {
        id: @id,
        title: @title,
        description: @description,
        icon: @icon,
        url: @url,
        children: @children.map(&:to_hash)
      }
    end

    def selected?(current_url)
      return false unless @url

      if @url == current_url
        true
      elsif SuperNavigation.config.highlight_on_subpath && current_url.start_with?(@url)
        true
      else
        @children.any? { |child| child.selected?(current_url) }
      end
    end
  end
end
