class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]

  def index
    @books = Book.order(created_at: :desc)
  end

  def show; end

  def new
    @book = Book.new
  end

  def edit; end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "Livro cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Livro atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @book.destroy
      redirect_to books_url, notice: "Livro removido com sucesso.", status: :see_other
    else
      redirect_to @book, alert: "Não foi possível remover o livro."
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

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
