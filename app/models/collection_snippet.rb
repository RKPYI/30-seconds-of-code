class CollectionSnippet < ApplicationRecord
  belongs_to :snippet, primary_key: 'cid', foreign_key: 'snippet_cid'
  belongs_to :collection, primary_key: 'cid', foreign_key: 'collection_cid'

  scope :by_position, -> { order('position asc') }
  scope :listed, -> { where.not(position: -1) }

  scope :published, -> do
    joins(:snippet).where(snippet: { date_modified: ..Date.today })
  end
end
