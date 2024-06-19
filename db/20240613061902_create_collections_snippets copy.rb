class CreateCollectionsSnippets < ActiveRecord::Migration[7.1]
  def change
    create_table :collections_snippets do |t|
      t.string :collection_cid
      t.string :snippet_cid
    end
    add_index :collections_snippets, :snippet_cid
    add_index :collections_snippets, :collection_cid
  end
end