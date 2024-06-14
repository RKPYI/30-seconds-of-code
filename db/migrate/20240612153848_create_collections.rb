class CreateCollections < ActiveRecord::Migration[7.1]
  def change
    create_table :collections do |t|
      t.string :cid
      t.string :name
      t.string :short_name
      t.string :mini_name
      t.string :slug
      t.boolean :featured
      t.integer :featured_index
      t.string :splash
      t.text :description
      t.text :short_description
      t.text :seo_description
      t.boolean :top_level
      t.boolean :allow_unlisted
      t.string :parent_cid
    end
    add_index :collections, :cid, unique: true
    add_index :collections, :parent_cid
  end
end
