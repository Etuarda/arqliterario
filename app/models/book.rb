class Book < ApplicationRecord

  enum status: {
    quero_ler: 0,
    lendo: 1,
    lido: 2,
    abandonado: 3
  }

  validates :title, :author, presence: true
end
