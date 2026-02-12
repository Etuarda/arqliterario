# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[index show search]
  before_action :authorize_owner!, only: %i[edit update destroy]

  def index
    @books = Book.includes(:user).order(created_at: :desc)
  end

  def show
  end

  def new
    # Prefill via querystring: /books/new?title=...&author=... etc
    @book = current_user.books.new(book_prefill_params)
  end

  def edit
  end

  def create
    @book = current_user.books.new(book_params)

    if @book.save
      redirect_to @book, notice: "Livro guardado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Livro atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "Livro removido com sucesso."
  end

  def search
    query = params[:query].to_s.strip
    results = OpenLibrary::SearchService.new(query: query).call

    render json: { results: results }
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def authorize_owner!
    return if @book.user_id == current_user.id

    redirect_to books_path, alert: "Você não tem permissão para editar este livro."
  end

  def book_params
    params.require(:book).permit(
      :title, :author, :published_year, :isbn, :image_url, :status
    )
  end

  # Permite prefill sem permitir status (status você pode controlar no form)
  def book_prefill_params
    params.permit(:title, :author, :published_year, :isbn, :image_url)
  end
end
