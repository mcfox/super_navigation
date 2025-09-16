# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperNavigation::Configuration do
  let(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(config.menu_data).to eq([])
      expect(config.auto_highlight).to be true
      expect(config.highlight_on_subpath).to be true
      expect(config.selected_class).to eq('selected')
    end
  end

  describe '#menu' do
    it 'creates menu items using DSL' do
      config.menu do
        item :dashboard, 'Dashboard', 'Main dashboard', 'fas fa-tachometer-alt', '/dashboard' do
          item :analytics, 'Analytics', 'View analytics', 'fas fa-chart-line', '/dashboard/analytics'
          item :reports, 'Reports', 'Generate reports', 'fas fa-file-alt', '/dashboard/reports'
        end
        
        item :users, 'Users', 'User management', 'fas fa-users', '/users' do
          item :user_list, 'User List', 'View all users', 'fas fa-list', '/users'
          item :new_user, 'New User', 'Create new user', 'fas fa-user-plus', '/users/new'
        end
      end

      expect(config.menu_data).to have(2).items
      
      dashboard_item = config.menu_data.first
      expect(dashboard_item.id).to eq('dashboard')
      expect(dashboard_item.title).to eq('Dashboard')
      expect(dashboard_item.description).to eq('Main dashboard')
      expect(dashboard_item.icon).to eq('fas fa-tachometer-alt')
      expect(dashboard_item.url).to eq('/dashboard')
      expect(dashboard_item.children).to have(2).items
      
      analytics_item = dashboard_item.children.first
      expect(analytics_item.id).to eq('analytics')
      expect(analytics_item.title).to eq('Analytics')
      expect(analytics_item.url).to eq('/dashboard/analytics')
    end
  end

  describe '#clear_menu!' do
    it 'clears all menu data' do
      config.menu do
        item :test, 'Test', 'Test item', 'fas fa-test', '/test'
      end

      expect(config.menu_data).not_to be_empty
      
      config.clear_menu!
      
      expect(config.menu_data).to be_empty
    end
  end
end
