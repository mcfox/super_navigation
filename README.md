# SuperNavigation

A `super_navigation` é uma gem Ruby on Rails que fornece uma DSL (Domain Specific Language) para definir menus de navegação complexos com múltiplos níveis, ícones, descrições, e funcionalidades avançadas como favoritos, itens usados recentemente e pesquisa. Ela se integra facilmente em aplicações Rails, oferecendo um botão de abertura de menu e um overlay responsivo com duas colunas.

## Compatibilidade com Rails 8

A gem `super_navigation` foi atualizada para ser compatível com o Rails 8, além de manter a compatibilidade com as versões 7.x. Foram feitos ajustes nas dependências e na forma como os assets são carregados para garantir um funcionamento adequado com o novo pipeline de assets (Propshaft) introduzido no Rails 8.

## Funcionalidades

*   **DSL intuitiva**: Defina a estrutura do seu menu de forma clara e concisa.
*   **Menu de duas colunas**: Navegação eficiente com itens de primeiro nível à esquerda e subitens à direita.
*   **Favoritos**: Os usuários podem marcar itens como favoritos para acesso rápido.
*   **Usados Recentemente**: Acompanha os últimos 10 itens acessados pelo usuário.
*   **Pesquisa Integrada**: Permite que os usuários pesquisem por qualquer item do menu.
*   **Customização**: Fácil de estilizar com CSS e estender com JavaScript.
*   **Integração com Rails**: Helpers para renderizar o botão de abertura e o menu completo em seus layouts.

## Instalação

Adicione esta linha ao `Gemfile` da sua aplicação:

```ruby
gem 'super_navigation', path: 'path/to/your/local/gem' # Para desenvolvimento local
# gem 'super_navigation' # Quando publicada no RubyGems
```

E então execute:

```bash
bundle install
```

### Configuração de Assets (Rails 7.x e 8)

Para garantir que os assets da gem sejam carregados corretamente, siga as instruções abaixo, dependendo da versão do seu Rails:

#### Rails 7.x (Sprockets)

No `app/assets/stylesheets/application.css` (ou `application.scss`):

```css
/*
 *= require super_navigation
 */
```

No `app/assets/javascripts/application.js`:

```javascript
// ...
//= require super_navigation
// ...
```

#### Rails 8 (Propshaft)

No `app/assets/config/manifest.js`, adicione as seguintes linhas:

```javascript
//= link super_navigation.css
//= link super_navigation.js
```

E no `config/initializers/assets.rb` (crie o arquivo se não existir), adicione:

```ruby
# config/initializers/assets.rb
Rails.application.config.assets.paths << SuperNavigation::Engine.root.join("vendor", "assets", "stylesheets")
Rails.application.config.assets.paths << SuperNavigation::Engine.root.join("vendor", "assets", "javascripts")
```

Certifique-se de ter o Font Awesome (ou outra biblioteca de ícones) incluído em seu projeto, pois a gem utiliza classes como `fas fa-star` para os ícones.

## Uso

### 1. Configurando o Menu (DSL)

Crie um arquivo de configuração para o seu menu, por exemplo, `config/initializers/super_navigation.rb`:

```ruby
# config/initializers/super_navigation.rb

SuperNavigation.configure do |config|
  config.auto_highlight = true # Opcional: define se o item atual deve ser destacado automaticamente
  config.selected_class = 'active' # Opcional: classe CSS para itens selecionados

  config.menu do
    item :dashboard, 'Dashboard', 'Visão geral do sistema', 'fas fa-tachometer-alt', '/dashboard'

    item :users, 'Usuários', 'Gerenciamento de usuários', 'fas fa-users', '/users' do
      item :user_list, 'Lista de Usuários', 'Ver todos os usuários', 'fas fa-list', '/users'
      item :new_user, 'Novo Usuário', 'Cadastrar novo usuário', 'fas fa-user-plus', '/users/new'
      item :roles, 'Perfis de Acesso', 'Gerenciar perfis', 'fas fa-user-tag', '/roles'
    end

    item :products, 'Produtos', 'Catálogo de produtos', 'fas fa-box', '/products' do
      item :product_list, 'Lista de Produtos', 'Ver todos os produtos', 'fas fa-boxes', '/products'
      item :new_product, 'Novo Produto', 'Adicionar novo produto', 'fas fa-plus-square', '/products/new'
      item :categories, 'Categorias', 'Gerenciar categorias', 'fas fa-tags', '/categories'
    end

    item :settings, 'Configurações', 'Ajustes do sistema', 'fas fa-cog', '/settings' do
      item :general, 'Geral', 'Configurações gerais', 'fas fa-cogs', '/settings/general'
      item :profile, 'Meu Perfil', 'Editar informações do perfil', 'fas fa-user-circle', '/settings/profile'
    end
  end
end
```

### 2. Renderizando o Menu no Layout

No seu arquivo de layout principal (por exemplo, `app/views/layouts/application.html.erb`), você pode renderizar o botão de abertura do menu e o menu em si:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>Minha Aplicação Rails</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbo-track': 'reload' %>
  
  <!-- Inclua o Font Awesome para os ícones -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</head>
<body>
  <header>
    <%= super_navigation_button %>
  </header>

  <main>
    <%= yield %>
  </main>

  <%= javascript_include_tag 'application', 'data-turbo-track': 'reload' %>
  <%= super_navigation_javascript_tag %>
</body>
</html>
```

*   `super_navigation_button`: Este helper renderiza o botão que abre o menu. Você pode passar opções para customizar o texto e o ícone do botão (ex: `super_navigation_button(button_text: 'Menu', button_icon: 'fas fa-bars')`).
*   `super_navigation_javascript_tag`: Este helper injeta os dados do menu configurados pela DSL no JavaScript, inicializando o menu. **É crucial que este helper seja chamado após a inclusão do `super_navigation.js` e antes do fechamento da tag `</body>`**.

### 3. Estrutura e Interação

*   **Estrutura**: O menu é um overlay com duas colunas. A esquerda para itens principais e a direita para subitens.
*   **Navegação**: Clicar em um subitem navega para a URL e o adiciona aos "Usados Recentemente".
*   **Favoritos**: Uma estrela ao lado de cada subitem permite favoritá-lo.
*   **Remoção**: Itens em "Favoritos" e "Usados Recentemente" podem ser removidos com um clique no 'X'.
*   **Pesquisa**: Um campo de busca filtra todos os itens do menu em tempo real.

## Desenvolvimento

Após clonar o repositório, execute `bin/setup` para instalar as dependências. Em seguida, execute `rake spec` para rodar os testes. Você também pode executar `bin/console` para um prompt interativo que permitirá experimentar.

Para instalar esta gem na sua máquina local, execute `bundle exec rake install`. Para lançar uma nova versão, atualize o número da versão em `version.rb` e, em seguida, execute `bundle exec rake release`, que criará uma tag git para a versão, enviará os commits git e a tag criada, e enviará o arquivo `.gem` para [rubygems.org](https://rubygems.org).

## Contribuição

Relatórios de bugs e pull requests são bem-vindos no GitHub em https://github.com/[USERNAME]/super_navigation.

## Licença

A gem está disponível como código aberto sob os termos da [Licença MIT](https://opensource.org/licenses/MIT).
