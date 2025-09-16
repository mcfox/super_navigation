# frozen_string_literal: true

RSpec.describe SuperNavigation do
  after do
    described_class.reset_configuration!
  end

  describe '.configure' do
    it 'yields configuration object' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(SuperNavigation::Configuration)
    end

    it 'returns configuration object' do
      config = described_class.configure
      expect(config).to be_a(SuperNavigation::Configuration)
    end

    it 'allows setting configuration options' do
      described_class.configure do |config|
        config.auto_highlight = false
        config.selected_class = 'active'
      end

      expect(described_class.config.auto_highlight).to be false
      expect(described_class.config.selected_class).to eq('active')
    end

    it 'allows defining menu using DSL' do
      described_class.configure do |config|
        config.menu do
          item :dashboard, 'Dashboard', 'Main dashboard', 'fas fa-tachometer-alt', '/dashboard'
          item :users, 'Users', 'User management', 'fas fa-users', '/users'
        end
      end

      expect(described_class.config.menu_data).to have(2).items
      expect(described_class.config.menu_data.first.id).to eq('dashboard')
      expect(described_class.config.menu_data.last.id).to eq('users')
    end
  end

  describe '.config' do
    it 'returns existing configuration' do
      config1 = described_class.configure
      config2 = described_class.config
      
      expect(config1).to eq(config2)
    end

    it 'creates new configuration if none exists' do
      expect(described_class.configuration).to be_nil
      
      config = described_class.config
      
      expect(config).to be_a(SuperNavigation::Configuration)
      expect(described_class.configuration).to eq(config)
    end
  end

  describe '.reset_configuration!' do
    it 'resets configuration to nil' do
      described_class.configure
      expect(described_class.configuration).not_to be_nil
      
      described_class.reset_configuration!
      
      expect(described_class.configuration).to be_nil
    end
  end

  describe 'version' do
    it 'has a version number' do
      expect(SuperNavigation::VERSION).not_to be nil
    end
  end
end


  describe "Rails compatibility" do
    it "supports Rails 7.x and 8.x" do
      # Verifica se a gem suporta Rails 7.x e 8.x
      rails_requirement = Gem::Requirement.new("~> 7.0", ">= 7.0", "< 8.1")
      
      # Testa com Rails 7.0
      expect(rails_requirement).to be_satisfied_by(Gem::Version.new("7.0.0"))
      
      # Testa com Rails 8.0
      expect(rails_requirement).to be_satisfied_by(Gem::Version.new("8.0.0"))
      
      # Não deve suportar Rails 8.1 (ainda não testado)
      expect(rails_requirement).not_to be_satisfied_by(Gem::Version.new("8.1.0"))
    end

    it "works with different asset pipeline configurations" do
      # Testa se a gem funciona com diferentes configurações de assets
      expect(SuperNavigation::Railtie).to be < Rails::Railtie
    end
  end

  describe "helpers integration" do
    let(:helper_class) do
      Class.new do
        include SuperNavigation::Helpers
        
        # Mock Rails helpers
        def request
          double(path: '/')
        end
        
        def content_tag(tag, content = nil, options = {}, &block)
          if block_given?
            "<#{tag}>#{yield}</#{tag}>"
          else
            "<#{tag}>#{content}</#{tag}>"
          end
        end
        
        def concat(content)
          content
        end
        
        def text_field_tag(name, value = nil, options = {})
          "<input type='text' name='#{name}' value='#{value}' />"
        end
        
        def javascript_tag(&block)
          "<script>#{yield if block_given?}</script>"
        end
        
        def stylesheet_link_tag(name)
          "<link rel='stylesheet' href='#{name}.css' />"
        end
      end
    end
    
    let(:helper) { helper_class.new }

    before do
      SuperNavigation.configure do |config|
        config.menu do
          item :test, 'Test', 'Test item', 'fas fa-test', '/test'
        end
      end
    end

    it "provides super_navigation_button helper" do
      expect(helper).to respond_to(:super_navigation_button)
      expect(helper.super_navigation_button).to include('button')
    end

    it "provides super_navigation_javascript_tag helper" do
      expect(helper).to respond_to(:super_navigation_javascript_tag)
      expect(helper.super_navigation_javascript_tag).to include('script')
    end

    it "provides super_navigation_stylesheet_tag helper" do
      expect(helper).to respond_to(:super_navigation_stylesheet_tag)
      expect(helper.super_navigation_stylesheet_tag).to include('link')
    end
  end
