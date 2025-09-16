/**
 * SuperNavigationMenu - Two-column navigation menu for Rails applications
 */
class SuperNavigationMenu {
  constructor() {
    this.menuData = [];
    this.favorites = this.loadFavorites();
    this.recentItems = this.loadRecentItems();
    this.currentPrimarySelection = null;
    this.isSearchMode = false;

    this.initializeElements();
    this.bindEvents();
    this.renderPrimaryMenu();
  }

  initializeElements() {
    this.openBtn = document.getElementById('openSuperMenuBtn');
    this.closeBtn = document.getElementById('closeSuperMenuBtn');
    this.overlay = document.getElementById('superMenuOverlay');
    this.primaryMenuItems = document.getElementById('superPrimaryMenuItems');
    this.secondaryMenuItems = document.getElementById('superSecondaryMenuItems');
    this.secondaryTitle = document.getElementById('superSecondaryTitle');
    this.searchInput = document.getElementById('superMenuSearchInput');
    this.clearSearchBtn = document.getElementById('clearSuperSearchBtn');
    this.menuContent = document.getElementById('superMenuContent');
    this.searchResults = document.getElementById('superSearchResults');
    this.searchResultsList = document.getElementById('superSearchResultsList');
    this.searchResultsHeader = document.getElementById('superSearchResultsHeader');
  }

  bindEvents() {
    if (this.openBtn) {
      this.openBtn.addEventListener('click', () => this.openMenu());
    }

    if (this.closeBtn) {
      this.closeBtn.addEventListener('click', () => this.closeMenu());
    }

    if (this.overlay) {
      this.overlay.addEventListener('click', (e) => {
        if (e.target === this.overlay) {
          this.closeMenu();
        }
      });
    }

    if (this.searchInput) {
      this.searchInput.addEventListener('input', (e) => this.handleSearch(e.target.value));
      this.searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
          this.clearSearch();
        }
      });
    }

    if (this.clearSearchBtn) {
      this.clearSearchBtn.addEventListener('click', () => this.clearSearch());
    }

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.overlay && this.overlay.classList.contains('active')) {
        this.closeMenu();
      }
    });
  }

  updateMenuData(newMenuData) {
    this.menuData = newMenuData;
    this.renderPrimaryMenu();
  }

  openMenu() {
    if (this.overlay) {
      this.overlay.classList.add('active');
      document.body.style.overflow = 'hidden';
      
      if (this.searchInput) {
        setTimeout(() => this.searchInput.focus(), 300);
      }
    }
  }

  closeMenu() {
    if (this.overlay) {
      this.overlay.classList.remove('active');
      document.body.style.overflow = '';
      this.clearSearch();
    }
  }

  renderPrimaryMenu() {
    if (!this.primaryMenuItems) return;

    this.primaryMenuItems.innerHTML = '';

    // Add Favorites section
    const favoritesItem = this.createPrimaryMenuItem({
      id: 'favorites',
      title: 'Favoritos',
      description: 'Seus itens favoritos do menu',
      icon: 'fas fa-star'
    });
    this.primaryMenuItems.appendChild(favoritesItem);

    // Add Recent Items section
    const recentItem = this.createPrimaryMenuItem({
      id: 'recent',
      title: 'Usados Recentemente',
      description: 'Últimos 10 itens acessados',
      icon: 'fas fa-clock'
    });
    this.primaryMenuItems.appendChild(recentItem);

    // Add separator
    const separator = document.createElement('div');
    separator.className = 'super-menu-separator';
    this.primaryMenuItems.appendChild(separator);

    // Add regular menu items
    this.menuData.forEach(item => {
      const menuItem = this.createPrimaryMenuItem(item);
      this.primaryMenuItems.appendChild(menuItem);
    });

    // Select first item by default
    if (this.menuData.length > 0) {
      this.selectPrimaryItem('favorites');
    }
  }

  createPrimaryMenuItem(item) {
    const menuItem = document.createElement('button');
    menuItem.className = 'super-menu-item';
    menuItem.dataset.itemId = item.id;

    menuItem.innerHTML = `
      <div class="super-menu-item-icon">
        <i class="${item.icon || 'fas fa-circle'}"></i>
      </div>
      <div class="super-menu-item-content">
        <div class="super-menu-item-title">${item.title}</div>
        <div class="super-menu-item-description">${item.description || ''}</div>
      </div>
    `;

    menuItem.addEventListener('click', () => this.selectPrimaryItem(item.id));

    return menuItem;
  }

  selectPrimaryItem(itemId) {
    // Update selection state
    const primaryItems = this.primaryMenuItems.querySelectorAll('.super-menu-item');
    primaryItems.forEach(item => item.classList.remove('selected'));

    const selectedItem = this.primaryMenuItems.querySelector(`[data-item-id="${itemId}"]`);
    if (selectedItem) {
      selectedItem.classList.add('selected');
    }

    this.currentPrimarySelection = itemId;

    // Render secondary menu based on selection
    if (itemId === 'favorites') {
      this.renderFavorites();
    } else if (itemId === 'recent') {
      this.renderRecentItems();
    } else {
      const menuItem = this.menuData.find(item => item.id === itemId);
      if (menuItem) {
        this.renderSecondaryMenu(menuItem);
      }
    }
  }

  renderSecondaryMenu(parentItem) {
    if (!this.secondaryMenuItems || !this.secondaryTitle) return;

    this.secondaryTitle.textContent = parentItem.title.toUpperCase();
    this.secondaryMenuItems.innerHTML = '';

    if (parentItem.children && parentItem.children.length > 0) {
      parentItem.children.forEach(child => {
        const menuItem = this.createSecondaryMenuItem(child, parentItem);
        this.secondaryMenuItems.appendChild(menuItem);
      });
    } else {
      this.renderEmptyState('Nenhum item disponível nesta categoria');
    }
  }

  renderFavorites() {
    if (!this.secondaryMenuItems || !this.secondaryTitle) return;

    this.secondaryTitle.textContent = 'FAVORITOS';
    this.secondaryMenuItems.innerHTML = '';

    if (this.favorites.length > 0) {
      this.favorites.forEach(favorite => {
        const menuItem = this.createSecondaryMenuItem(favorite, null, 'favorites');
        this.secondaryMenuItems.appendChild(menuItem);
      });
    } else {
      this.renderEmptyState('Nenhum item favoritado ainda');
    }
  }

  renderRecentItems() {
    if (!this.secondaryMenuItems || !this.secondaryTitle) return;

    this.secondaryTitle.textContent = 'USADOS RECENTEMENTE';
    this.secondaryMenuItems.innerHTML = '';

    if (this.recentItems.length > 0) {
      this.recentItems.forEach(recent => {
        const menuItem = this.createSecondaryMenuItem(recent, null, 'recent');
        this.secondaryMenuItems.appendChild(menuItem);
      });
    } else {
      this.renderEmptyState('Nenhum item acessado recentemente');
    }
  }

  createSecondaryMenuItem(item, parentItem, listType = null) {
    const menuItem = document.createElement('button');
    menuItem.className = 'super-menu-item';
    menuItem.dataset.itemId = item.id;
    if (parentItem) {
      menuItem.dataset.parentId = parentItem.id;
    }

    const isFavorited = this.favorites.some(fav => fav.id === item.id);
    const showRemoveBtn = listType === 'favorites' || listType === 'recent';

    menuItem.innerHTML = `
      <div class="super-menu-item-icon">
        <i class="${item.icon || 'fas fa-circle'}"></i>
      </div>
      <div class="super-menu-item-content">
        <div class="super-menu-item-title">${item.title}</div>
        <div class="super-menu-item-description">${item.description || ''}</div>
      </div>
      <div class="super-menu-item-actions">
        ${!showRemoveBtn ? `
          <button class="super-favorite-btn ${isFavorited ? 'favorited' : ''}" 
                  title="${isFavorited ? 'Remover dos favoritos' : 'Adicionar aos favoritos'}">
            <i class="fas fa-star"></i>
          </button>
        ` : `
          <button class="super-remove-btn" 
                  title="Remover dos ${listType === 'favorites' ? 'favoritos' : 'recentes'}">
            <i class="fas fa-times"></i>
          </button>
        `}
      </div>
    `;

    // Add click event for navigation
    const contentArea = menuItem.querySelector('.super-menu-item-content');
    if (contentArea) {
      contentArea.addEventListener('click', () => this.navigateToItem(item, parentItem));
    }

    // Add click event for favorite button
    const favoriteBtn = menuItem.querySelector('.super-favorite-btn');
    if (favoriteBtn) {
      favoriteBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.toggleFavorite(item, parentItem);
      });
    }

    // Add click event for remove button
    const removeBtn = menuItem.querySelector('.super-remove-btn');
    if (removeBtn) {
      removeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.removeFromSpecialList(item, listType);
      });
    }

    return menuItem;
  }

  renderEmptyState(message) {
    this.secondaryMenuItems.innerHTML = `
      <div class="super-empty-state">
        <i class="fas fa-folder-open"></i>
        <p>${message}</p>
      </div>
    `;
  }

  navigateToItem(item, parentItem) {
    if (item.url) {
      this.addToRecentItems(item, parentItem);
      
      // Close menu and navigate
      this.closeMenu();
      
      // Navigate to URL
      if (typeof window !== 'undefined') {
        window.location.href = item.url;
      }
    }
  }

  toggleFavorite(item, parentItem) {
    const existingIndex = this.favorites.findIndex(fav => fav.id === item.id);
    
    if (existingIndex >= 0) {
      this.favorites.splice(existingIndex, 1);
    } else {
      const favoriteItem = { ...item };
      if (parentItem) {
        favoriteItem.parentTitle = parentItem.title;
      }
      this.favorites.push(favoriteItem);
    }

    this.saveFavorites();
    
    // Refresh current view
    if (this.currentPrimarySelection === 'favorites') {
      this.renderFavorites();
    } else {
      // Update the favorite button in the current secondary menu
      const menuItem = this.secondaryMenuItems.querySelector(`[data-item-id="${item.id}"]`);
      if (menuItem) {
        const favoriteBtn = menuItem.querySelector('.super-favorite-btn');
        if (favoriteBtn) {
          const isFavorited = this.favorites.some(fav => fav.id === item.id);
          favoriteBtn.classList.toggle('favorited', isFavorited);
          favoriteBtn.title = isFavorited ? 'Remover dos favoritos' : 'Adicionar aos favoritos';
        }
      }
    }
  }

  removeFromSpecialList(item, listType) {
    if (listType === 'favorites') {
      const index = this.favorites.findIndex(fav => fav.id === item.id);
      if (index >= 0) {
        this.favorites.splice(index, 1);
        this.saveFavorites();
        this.renderFavorites();
      }
    } else if (listType === 'recent') {
      const index = this.recentItems.findIndex(recent => recent.id === item.id);
      if (index >= 0) {
        this.recentItems.splice(index, 1);
        this.saveRecentItems();
        this.renderRecentItems();
      }
    }
  }

  addToRecentItems(item, parentItem) {
    // Remove if already exists
    const existingIndex = this.recentItems.findIndex(recent => recent.id === item.id);
    if (existingIndex >= 0) {
      this.recentItems.splice(existingIndex, 1);
    }

    // Add to beginning
    const recentItem = { ...item };
    if (parentItem) {
      recentItem.parentTitle = parentItem.title;
    }
    this.recentItems.unshift(recentItem);

    // Keep only last 10 items
    if (this.recentItems.length > 10) {
      this.recentItems = this.recentItems.slice(0, 10);
    }

    this.saveRecentItems();
  }

  handleSearch(query) {
    if (!query.trim()) {
      this.clearSearch();
      return;
    }

    this.isSearchMode = true;
    this.clearSearchBtn.style.display = 'block';
    this.menuContent.style.display = 'none';
    this.searchResults.classList.add('active');

    const results = this.searchItems(query);
    this.renderSearchResults(results, query);
  }

  searchItems(query) {
    const results = [];
    const searchTerm = query.toLowerCase();

    // Search in favorites
    this.favorites.forEach(item => {
      if (this.itemMatchesSearch(item, searchTerm)) {
        results.push({
          ...item,
          breadcrumb: 'Favoritos'
        });
      }
    });

    // Search in recent items
    this.recentItems.forEach(item => {
      if (this.itemMatchesSearch(item, searchTerm) && 
          !results.some(r => r.id === item.id)) {
        results.push({
          ...item,
          breadcrumb: 'Usados Recentemente'
        });
      }
    });

    // Search in regular menu items
    this.menuData.forEach(parentItem => {
      if (parentItem.children) {
        parentItem.children.forEach(child => {
          if (this.itemMatchesSearch(child, searchTerm) && 
              !results.some(r => r.id === child.id)) {
            results.push({
              ...child,
              breadcrumb: parentItem.title,
              parentItem: parentItem
            });
          }
        });
      }
    });

    return results;
  }

  itemMatchesSearch(item, searchTerm) {
    return (
      item.title.toLowerCase().includes(searchTerm) ||
      (item.description && item.description.toLowerCase().includes(searchTerm))
    );
  }

  renderSearchResults(results, query) {
    this.searchResultsHeader.textContent = `Resultados para "${query}"`;
    this.searchResultsList.innerHTML = '';

    if (results.length > 0) {
      results.forEach(result => {
        const resultItem = this.createSearchResultItem(result);
        this.searchResultsList.appendChild(resultItem);
      });
    } else {
      this.searchResultsList.innerHTML = `
        <div class="super-no-results">
          <i class="fas fa-search"></i>
          <p>Nenhum resultado encontrado para "${query}"</p>
        </div>
      `;
    }
  }

  createSearchResultItem(result) {
    const resultItem = document.createElement('button');
    resultItem.className = 'super-search-result-item';

    resultItem.innerHTML = `
      <div class="super-menu-item-icon">
        <i class="${result.icon || 'fas fa-circle'}"></i>
      </div>
      <div class="super-menu-item-content">
        <div class="super-menu-item-title">${result.title}</div>
        <div class="super-menu-item-description">${result.description || ''}</div>
        <div class="super-search-result-breadcrumb">${result.breadcrumb}</div>
      </div>
    `;

    resultItem.addEventListener('click', () => {
      this.navigateToItem(result, result.parentItem);
    });

    return resultItem;
  }

  clearSearch() {
    if (this.searchInput) {
      this.searchInput.value = '';
    }
    
    if (this.clearSearchBtn) {
      this.clearSearchBtn.style.display = 'none';
    }

    this.isSearchMode = false;
    
    if (this.menuContent) {
      this.menuContent.style.display = 'flex';
    }
    
    if (this.searchResults) {
      this.searchResults.classList.remove('active');
    }
  }

  // Local storage methods
  loadFavorites() {
    try {
      const stored = localStorage.getItem('superNavigation.favorites');
      return stored ? JSON.parse(stored) : [];
    } catch (e) {
      return [];
    }
  }

  saveFavorites() {
    try {
      localStorage.setItem('superNavigation.favorites', JSON.stringify(this.favorites));
    } catch (e) {
      console.warn('Could not save favorites to localStorage');
    }
  }

  loadRecentItems() {
    try {
      const stored = localStorage.getItem('superNavigation.recentItems');
      return stored ? JSON.parse(stored) : [];
    } catch (e) {
      return [];
    }
  }

  saveRecentItems() {
    try {
      localStorage.setItem('superNavigation.recentItems', JSON.stringify(this.recentItems));
    } catch (e) {
      console.warn('Could not save recent items to localStorage');
    }
  }
}

// Auto-initialize if DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('openSuperMenuBtn')) {
      window.superNavigationMenu = new SuperNavigationMenu();
    }
  });
} else {
  if (document.getElementById('openSuperMenuBtn')) {
    window.superNavigationMenu = new SuperNavigationMenu();
  }
}
