class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.integer :published_year
      t.string :isbn
      t.string :image_url
      t.integer :status

      t.timestamps
    end
  end
end
