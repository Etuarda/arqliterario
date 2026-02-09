FROM ruby:3.3.4

# Why: evita prompts interativos durante instalação de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Dependências do sistema
# - build-essential: compilar gems nativas
# - libsqlite3-dev: suporte ao SQLite
# - nodejs: requerido pelo importmap / assets do Rails
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libsqlite3-dev \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# Diretório padrão da aplicação
WORKDIR /app


# aproveita cache de camadas do Docker
COPY Gemfile Gemfile.lock ./

# Instala gems
RUN bundle install

# Copiamos o restante do código da aplicação
COPY . .

# Porta padrão 
EXPOSE 3000

# Comando padrão do container
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
