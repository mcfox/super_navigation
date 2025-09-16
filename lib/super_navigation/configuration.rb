# frozen_string_literal: true

module SuperNavigation
  class Configuration
    attr_accessor :menu_data, :auto_highlight, :highlight_on_subpath, :selected_class

    def initialize
      @menu_data = []
      @auto_highlight = true
      @highlight_on_subpath = true
      @selected_class = 'selected'
    end

    def menu(&block)
      container = ItemContainer.new
      container.instance_eval(&block) if block_given?
      @menu_data = container.items
    end

    def clear_menu!
      @menu_data = []
    end
  end
end
