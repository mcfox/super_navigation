# frozen_string_literal: true

module SuperNavigation
  class Railtie < Rails::Railtie
    initializer "super_navigation.helpers" do
      ActiveSupport.on_load(:action_view) do
        include SuperNavigation::Helpers
      end
    end

    initializer "super_navigation.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w[super_navigation.css super_navigation.js]
      end
      
      # Para Rails 8 com Propshaft
      if defined?(Propshaft)
        gem_root = File.expand_path('../../..', __FILE__)
        stylesheets_path = File.join(gem_root, "vendor", "assets", "stylesheets")
        javascripts_path = File.join(gem_root, "vendor", "assets", "javascripts")
        
        app.config.assets.paths << stylesheets_path if File.exist?(stylesheets_path)
        app.config.assets.paths << javascripts_path if File.exist?(javascripts_path)
      end
    end
  end
end
