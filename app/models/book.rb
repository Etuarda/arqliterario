# frozen_string_literal: true

class Book < ApplicationRecord
  belongs_to :user

  enum status: {
    quero_ler: 0,
    lendo: 1,
    lido: 2,
    abandonado: 3
  }

  validates :title, :author, presence: true

  def status_label
    return "" if status.blank?

    I18n.t(
      "activerecord.attributes.book.status.#{status}",
      default: status.humanize
    )
  end
end
