# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperNavigation::ItemContainer do
  let(:container) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty items array' do
      expect(container.items).to eq([])
    end
  end

  describe '#item' do
    it 'creates and adds a simple item' do
      item = container.item(:test, 'Test Item', 'Test description', 'fas fa-test', '/test')
      
      expect(container.items).to have(1).item
      expect(container.items.first).to eq(item)
      expect(item.id).to eq('test')
      expect(item.title).to eq('Test Item')
      expect(item.description).to eq('Test description')
      expect(item.icon).to eq('fas fa-test')
      expect(item.url).to eq('/test')
    end

    it 'creates item with children using block' do
      parent_item = container.item(:parent, 'Parent Item', 'Parent description', 'fas fa-parent', '/parent') do
        item :child1, 'Child 1', 'First child', 'fas fa-child', '/parent/child1'
        item :child2, 'Child 2', 'Second child', 'fas fa-child', '/parent/child2'
      end
      
      expect(container.items).to have(1).item
      expect(parent_item.children).to have(2).items
      
      child1 = parent_item.children.first
      expect(child1.id).to eq('child1')
      expect(child1.title).to eq('Child 1')
      expect(child1.url).to eq('/parent/child1')
      
      child2 = parent_item.children.last
      expect(child2.id).to eq('child2')
      expect(child2.title).to eq('Child 2')
      expect(child2.url).to eq('/parent/child2')
    end

    it 'creates multiple top-level items' do
      container.item(:item1, 'Item 1')
      container.item(:item2, 'Item 2')
      container.item(:item3, 'Item 3')
      
      expect(container.items).to have(3).items
      expect(container.items.map(&:id)).to eq(['item1', 'item2', 'item3'])
    end

    it 'handles nested children' do
      container.item(:level1, 'Level 1') do
        item :level2, 'Level 2' do
          item :level3, 'Level 3'
        end
      end
      
      level1 = container.items.first
      level2 = level1.children.first
      level3 = level2.children.first
      
      expect(level1.id).to eq('level1')
      expect(level2.id).to eq('level2')
      expect(level3.id).to eq('level3')
    end
  end

  describe '#clear!' do
    it 'removes all items' do
      container.item(:test1, 'Test 1')
      container.item(:test2, 'Test 2')
      
      expect(container.items).to have(2).items
      
      container.clear!
      
      expect(container.items).to be_empty
    end
  end
end
