class Collection < ApplicationRecord
  MAIN_COLLECTION_CID = 'snippets'.freeze
  MORE_COLLECTIONS_SUBLINK = {
    title: 'More',
    url: '/collections/p/1',
    icon: 'arrow-right',
    selected: false
  }.freeze

  # Change primary key to `cid` to make `find` available
  self.primary_key = :cid

  # https://guides.rubyonrails.org/v5.0/association_basics.html
  has_one :parent,
    class_name: 'Collection',
    foreign_key: 'cid',
    primary_key: 'parent_cid',
    inverse_of: :children
  has_many :children,
    class_name: 'Collection',
    foreign_key: 'parent_cid',
    primary_key: 'cid',
    inverse_of: :parent

  has_many :collection_snippets,
    foreign_key: 'collection_cid'

  has_many :snippets,
    through: :collection_snippets

  scope :with_parent, -> { where.not(parent_cid: nil) }
  scope :primary, -> { where(top_level: true) }
  scope :secondary, -> { with_parent }
  scope :listed, -> { where(featured: true) }
  scope :ranked, -> { listed.order('ranking desc') }
  scope :featured, -> { listed.order('featured_index asc') }

  def self.main
    find(MAIN_COLLECTION_CID)
  end

  def slug
    cid.to_seo_slug
  end

  def seo_description
    short_description.strip_markdown
  end

  def has_parent?
    parent.present?
  end

  def is_main?
    cid == MAIN_COLLECTION_CID
  end

  def is_primary?
    top_level?
  end

  def is_secondary?
    has_parent?
  end

  def root_url
    has_parent? ? parent.slug : slug
  end

  def siblings
    has_parent? ? parent.children : []
  end

  def siblings_except_self
    siblings - [self]
  end

  def is_searchable
    featured?
  end

  def search_tokens
    _tokens.split(';')
  end

  def first_page_slug
    "#{slug}/p/1"
  end

  def page_count
    # TODO:  cardsPerPage setting
    (snippets.count / 24.0).ceil
  end

  def listed_snippets
    Snippet.
      published.
      joins(:collection_snippets).
      where(collection_snippets: { collection_cid: cid }).
      where.not(collection_snippets: { position: -1 }).
      order('collection_snippets.position asc')
  end

  def formatted_snippet_count
    "#{listed_snippets.count} snippets"
  end

  def formatted_description
    description.strip_html_paragraphs_and_links
  end

  def sublinks
    if is_main?
      return Collection.
              primary.
              ranked.
              map(&:to_sublink).
              flatten.
              append(MORE_COLLECTIONS_SUBLINK)
    end

    return [] if !is_primary? && !has_parent?
    return [] if is_primary? && children.empty?

    (has_parent? ? siblings : children).map do |link|
      link.to_sublink(cid)
    end.prepend({
      title: 'All',
      url: "#{root_url}/p/1",
      selected: is_primary?
    })
  end

  def to_sublink(collection_cid = nil)
    {
      title: mini_name,
      url: first_page_slug,
      selected: collection_cid == cid
    }
  end

  # TODO: A little fiddly
  def matches_tag(tag)
    cid.end_with?("/#{tag}")
  end
end
