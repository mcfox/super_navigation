# frozen_string_literal: true

require_relative "super_navigation/version"
require_relative "super_navigation/configuration"
require_relative "super_navigation/item"
require_relative "super_navigation/item_container"
require_relative "super_navigation/helpers"
require_relative "super_navigation/railtie" if defined?(Rails)

module SuperNavigation
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      configuration
    end

    def config
      configuration || configure
    end

    def reset_configuration!
      self.configuration = nil
    end
  end
end
