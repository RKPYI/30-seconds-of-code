class CreateSnippets < ActiveRecord::Migration[7.1]
  def change
    create_table :snippets do |t|
      t.string :cid
      t.string :file_name
      t.string :title
      t.string :_tags
      t.string :short_title
      t.date :date_modified
      t.boolean :listed
      t.string :ctype
      t.text :short_text
      t.text :full_text
      t.text :description_html
      t.text :full_description_html
      t.string :cover
      t.text :seo_description
      t.string :language_cid
    end
    add_index :snippets, :cid, unique: true
    add_index :snippets, :language_cid    
  end
end
