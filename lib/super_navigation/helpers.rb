# frozen_string_literal: true

module SuperNavigation
  module Helpers
    def super_navigation_button(options = {})
      render_menu_button(options)
    end

    def render_super_navigation(options = {})
      menu_data = SuperNavigation.config.menu_data
      return '' if menu_data.empty?

      current_url = request.path
      menu_data_json = menu_data.map(&:to_hash).to_json

      content_tag(:div, id: 'super-navigation-container') do
        concat(render_menu_button(options))
        concat(render_menu_overlay(menu_data_json, current_url, options))
      end
    end

    def render_menu_button(options = {})
      button_text = options[:button_text] || 'Abrir Menu'
      button_icon = options[:button_icon] || 'fas fa-bars'
      button_class = options[:button_class] || 'super-navigation-btn'

      content_tag(:button, id: 'openSuperMenuBtn', class: button_class) do
        concat(content_tag(:i, '', class: button_icon))
        concat(' ')
        concat(button_text)
      end
    end

    def render_menu_overlay(menu_data_json, current_url, options = {})
      content_tag(:div, id: 'superMenuOverlay', class: 'super-menu-overlay') do
        content_tag(:div, class: 'super-menu-container') do
          concat(render_menu_header(options))
          concat(render_menu_search)
          concat(render_menu_content)
          concat(render_search_results)
        end
      end
    end

    def render_menu_header(options = {})
      title = options[:title] || 'Menu Principal'
      
      content_tag(:div, class: 'super-menu-header') do
        concat(content_tag(:h2, title))
        concat(content_tag(:button, id: 'closeSuperMenuBtn', class: 'super-menu-close-btn') do
          content_tag(:i, '', class: 'fas fa-times')
        end)
      end
    end

    def render_menu_search
      content_tag(:div, class: 'super-menu-search') do
        content_tag(:div, class: 'super-search-container') do
          concat(content_tag(:i, '', class: 'fas fa-search super-search-icon'))
          concat(text_field_tag('superMenuSearchInput', '', 
                               placeholder: 'Pesquisar no menu...', 
                               class: 'super-search-input',
                               id: 'superMenuSearchInput'))
          concat(content_tag(:button, id: 'clearSuperSearchBtn', 
                            class: 'super-clear-search-btn', 
                            style: 'display: none;') do
            content_tag(:i, '', class: 'fas fa-times')
          end)
        end
      end
    end

    def render_menu_content
      content_tag(:div, class: 'super-menu-content', id: 'superMenuContent') do
        concat(content_tag(:div, class: 'super-menu-column super-menu-column-primary') do
          concat(content_tag(:div, 'Categorias', class: 'super-menu-section-title'))
          concat(content_tag(:div, '', id: 'superPrimaryMenuItems', class: 'super-menu-items'))
        end)
        concat(content_tag(:div, class: 'super-menu-column super-menu-column-secondary') do
          concat(content_tag(:div, 'Selecione uma categoria', 
                            class: 'super-menu-section-title', 
                            id: 'superSecondaryTitle'))
          concat(content_tag(:div, '', id: 'superSecondaryMenuItems', class: 'super-menu-items'))
        end)
      end
    end

    def render_search_results
      content_tag(:div, class: 'super-search-results', id: 'superSearchResults') do
        concat(content_tag(:div, 'Resultados da pesquisa', 
                          class: 'super-search-results-header', 
                          id: 'superSearchResultsHeader'))
        concat(content_tag(:div, '', 
                          class: 'super-search-results-list', 
                          id: 'superSearchResultsList'))
      end
    end

    def super_navigation_javascript_tag
      menu_data = SuperNavigation.config.menu_data
      menu_data_json = menu_data.map(&:to_hash).to_json

      javascript_tag do
        <<~JS.html_safe
          document.addEventListener('DOMContentLoaded', function() {
            if (typeof SuperNavigationMenu !== 'undefined') {
              window.superNavigationMenu = new SuperNavigationMenu();
              window.superNavigationMenu.updateMenuData(#{menu_data_json});
            }
          });
        JS
      end
    end

    def super_navigation_stylesheet_tag
      stylesheet_link_tag('super_navigation')
    end
  end
end
