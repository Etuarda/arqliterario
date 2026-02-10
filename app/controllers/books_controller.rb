class BooksController < ApplicationController
  # -------------------------------------------------------------------
  # Autenticação e autorização
  #
  # - Visitantes podem apenas listar e visualizar livros.
  # - Criação, edição e remoção exigem usuário autenticado.
  # -------------------------------------------------------------------
  before_action :authenticate_user!, except: %i[index show]

  # Centraliza o carregamento do livro para ações que dependem de um registro.
  before_action :set_book, only: %i[show edit update destroy]

  # Garante que apenas o dono do livro possa alterá-lo ou removê-lo.
  before_action :authorize_owner!, only: %i[edit update destroy]

  # GET /books
  #
  # Lista pública de livros.
  # Inclui o usuário para evitar N+1 queries na renderização.
  def index
    @books = Book.includes(:user).order(created_at: :desc)
  end

  # GET /books/:id
  #
  # Exibição pública de um livro.
  def show; end

  # GET /books/new
  #
  # Inicializa um livro já associado ao usuário logado.
  def new
    @book = current_user.books.new
  end

  # GET /books/:id/edit
  def edit; end

  # POST /books
  #
  # Persistência do livro.
  # A associação com o usuário vem do contexto da sessão (current_user),
  # nunca do payload da requisição.
  def create
    @book = current_user.books.new(book_params)

    if @book.save
      redirect_to @book, notice: "Livro cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/:id
  #
  # Atualiza apenas atributos permitidos do livro.
  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Livro atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /books/:id
  #
  # Remove o livro.
  # Usamos destroy (sem bang) para evitar exceções não tratadas em produção.
  def destroy
    if @book.destroy
      redirect_to books_url, notice: "Livro removido com sucesso.", status: :see_other
    else
      redirect_to @book, alert: "Não foi possível remover o livro."
    end
  end

  private

  # -------------------------------------------------------------------
  # Métodos auxiliares
  # -------------------------------------------------------------------

  # Encapsula a busca do livro e evita duplicação de código.
  def set_book
    @book = Book.find(params[:id])
  end

  # Regra de ownership:
  # somente o usuário que criou o livro pode modificá-lo.
  def authorize_owner!
    return if @book.user_id == current_user.id

    redirect_to books_path, alert: "Sem permissão para alterar este livro."
  end

  # Contrato explícito dos atributos permitidos.
  # user_id não é aceito via params para evitar mass assignment indevido.
  def book_params
    params.require(:book).permit(
      :title,
      :author,
      :published_year,
      :isbn,
      :image_url,
      :status
    )
  end
end
