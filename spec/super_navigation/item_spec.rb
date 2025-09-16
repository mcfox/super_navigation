# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperNavigation::Item do
  let(:item) { described_class.new(:test, 'Test Item', 'Test description', 'fas fa-test', '/test') }

  describe '#initialize' do
    it 'sets all attributes correctly' do
      expect(item.id).to eq('test')
      expect(item.title).to eq('Test Item')
      expect(item.description).to eq('Test description')
      expect(item.icon).to eq('fas fa-test')
      expect(item.url).to eq('/test')
      expect(item.children).to eq([])
      expect(item.options).to eq({})
    end

    it 'converts id to string' do
      item = described_class.new(123, 'Test')
      expect(item.id).to eq('123')
    end
  end

  describe '#add_child' do
    it 'adds a child item' do
      child = described_class.new(:child, 'Child Item', 'Child description', 'fas fa-child', '/test/child')
      item.add_child(child)
      
      expect(item.children).to include(child)
      expect(item.children.size).to eq(1)
    end
  end

  describe '#has_children?' do
    it 'returns false when no children' do
      expect(item.has_children?).to be false
    end

    it 'returns true when has children' do
      child = described_class.new(:child, 'Child Item')
      item.add_child(child)
      
      expect(item.has_children?).to be true
    end
  end

  describe '#to_hash' do
    it 'returns hash representation' do
      child = described_class.new(:child, 'Child Item', 'Child description', 'fas fa-child', '/test/child')
      item.add_child(child)
      
      hash = item.to_hash
      
      expect(hash[:id]).to eq('test')
      expect(hash[:title]).to eq('Test Item')
      expect(hash[:description]).to eq('Test description')
      expect(hash[:icon]).to eq('fas fa-test')
      expect(hash[:url]).to eq('/test')
      expect(hash[:children]).to have(1).item
      expect(hash[:children].first[:id]).to eq('child')
    end
  end

  describe '#selected?' do
    before do
      allow(SuperNavigation).to receive(:config).and_return(
        double(highlight_on_subpath: true)
      )
    end

    it 'returns true for exact URL match' do
      expect(item.selected?('/test')).to be true
    end

    it 'returns false for non-matching URL' do
      expect(item.selected?('/other')).to be false
    end

    it 'returns true for subpath when highlight_on_subpath is enabled' do
      expect(item.selected?('/test/subpage')).to be true
    end

    it 'returns false for subpath when highlight_on_subpath is disabled' do
      allow(SuperNavigation.config).to receive(:highlight_on_subpath).and_return(false)
      expect(item.selected?('/test/subpage')).to be false
    end

    it 'returns true when child is selected' do
      child = described_class.new(:child, 'Child Item', nil, nil, '/test/child')
      item.add_child(child)
      
      expect(item.selected?('/test/child')).to be true
    end

    it 'returns false when item has no URL' do
      item_without_url = described_class.new(:test, 'Test Item')
      expect(item_without_url.selected?('/test')).to be false
    end
  end
end
