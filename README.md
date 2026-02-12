# 📚 Arquivo Literário

**Desafio Técnico de Estágio – Portal (Ruby on Rails)**

O **Arquivo Literário** é uma aplicação desenvolvida em Ruby on Rails que permite o cadastro e exibição de livros lidos.
A aplicação foi construída seguindo integralmente os requisitos do desafio técnico, incluindo autenticação, integração obrigatória com API externa, organização de código e execução via Docker.

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

* Docker
* Docker Compose

### 1️⃣ Clonar o repositório

```bash
git clone https://github.com/seu-usuario/arquivo-literario.git
cd arquivo-literario
```

### 2️⃣ Subir os containers

```bash
docker compose up --build
```

### 3️⃣ Preparar o banco de dados

Em outro terminal:

```bash
docker compose exec web rails db:prepare
```

### 4️⃣ Acessar a aplicação

Abra no navegador:

```
http://localhost:3000
```

Caso nenhuma instrução adicional seja seguida, a aplicação também sobe apenas com:

```bash
docker compose up
```

---

## 🧱 Funcionalidades Implementadas

### 🌍 Acesso Público

* Listagem de todos os livros cadastrados por todos os usuários.
* Header com botões de **Login** e **Criar Conta**.
* Se o usuário estiver autenticado, o nome é exibido na interface.

---

### 🔐 Área Autenticada

Usuários autenticados podem:

* Cadastrar novos livros
* Editar apenas os livros que cadastraram
* Remover apenas os livros que cadastraram
* Visualizar estatísticas pessoais (lidos, lendo, desejados)
* Pesquisar dentro da própria biblioteca

---

## 🔎 Fluxo de Cadastro com Integração OpenLibrary

O fluxo implementado segue exatamente o requisito obrigatório do desafio:

1. O usuário informa o título do livro.
2. O backend (Rails) realiza a requisição à API da OpenLibrary.
3. A requisição é feita exclusivamente no backend utilizando uma gem HTTP.
4. O frontend recebe os resultados via JSON.
5. O usuário seleciona o livro desejado.
6. Os dados retornados são persistidos no banco.

A requisição externa não é feita no frontend, respeitando integralmente o enunciado.

---

## 🛠️ Tecnologias Utilizadas

* Ruby on Rails 7
* SQLite
* Docker & Docker Compose
* Devise (autenticação)
* HTTParty (requisições HTTP)
* TailwindCSS
* Hotwire (Turbo + Stimulus)

---

## 📂 Estrutura de Versionamento

O repositório segue uma organização clara:

1. Commit inicial contendo apenas o código gerado pelo `rails new`.
2. Commits separados para:

   * Autenticação
   * Integração com API
   * CRUD de livros
   * Ajustes de UI
   * Dockerização
   * Correções de lógica

---

## 🤖 Uso de Inteligência Artificial

Assistentes de IA foram utilizados como ferramenta de apoio para:

* Estruturação inicial de arquivos
* Ajustes na configuração Docker
* Apoio na integração com API externa
* Sugestões de organização de interface

### Exemplo Real de Correção Durante o Desenvolvimento

Durante o desenvolvimento, tive um erro na página inicial porque a view estava tentando usar uma variável que não estava sendo definida no controller. Isso causava um `NoMethodError` ao acessar a lista de livros.

Ao revisar a lógica, percebi que eu havia alterado o nome da variável na view, mas não tinha ajustado a action `index`. Corrigi organizando melhor o controller, separando os livros públicos dos livros do usuário logado e garantindo que todas as variáveis usadas na view fossem sempre inicializadas.

Também ajustei a barra de pesquisa da área logada. Inicialmente ela estava apenas visual (input desabilitado), então implementei a lógica no backend para filtrar os livros do usuário com base no termo digitado. Dessa forma, ela passou a ter comportamento real e não apenas aparência de funcionalidade.

Esses ajustes envolveram tanto backend (controller e lógica de consulta) quanto frontend (estrutura da view e comportamento do input), garantindo coerência entre interface e regra de negócio.

---

## 📌 Pontos Técnicos Relevantes

* Separação clara entre conteúdo público e privado na action `index`
* Controle de autorização para edição e remoção
* Enum para status de leitura
* Integração backend-first com API externa
* Estrutura organizada seguindo convenções Rails
* Aplicação executável via Docker



Projeto desenvolvido para fins de avaliação técnica, por Eduarda Silva Santos.
