class PreviewSerializer < BaseSerializer
  attributes :title, :url, :cover, :cover_srcset, :tags,
             :extra_context, :date_time

  attribute :formatted_description, as: :description

  # TODO: Possibly extract the cover logic into a presenter finally.
  # Also, as the logic for covers is fairly complex, we might as well use Parsley
  # to rename fields to match on the models and we can then match them on the MD
  # side later down the line, too.
  COVER_PREFIXES = {
    snippet: '/assets/cover/',
    collection: '/assets/splash/'
  }.freeze
  COVER_SUFFIX = {
    snippet: '-400',
    collection: '-600'
  }.freeze
  COVER_EXTENSION = '.webp'.freeze
  COVER_SIZES = {
    snippet: %w(400w 800w),
    collection: %w(400w 600w)
  }.freeze
  COLLECTION_TAG_LITERAL = 'Collection'.freeze

  attr_reader :options

  def title
    is_snippet? ? object.title : object.name
  end

  def cover
    "#{cover_prefix}#{cover_name}#{cover_suffix}#{COVER_EXTENSION}"
  end

  def cover_srcset
    cover_sizes.map do |size|
      suffix = size.delete('w')
      "#{cover_prefix}#{cover_name}-#{suffix}#{COVER_EXTENSION} #{size}"
    end
  end

  def url
    is_snippet? ? object.slug : object.first_page_slug
  end

  def tags
    is_snippet? ? object.formatted_preview_tags : COLLECTION_TAG_LITERAL
  end

  def extra_context
    is_snippet? ? object.date_formatted : object.formatted_snippet_count
  end

  def include_date_time?
    is_snippet?
  end

  def date_time
    object.date_machine_formatted
  end

  private

  def is_snippet?
    object.is_a?(Snippet)
  end

  def cover_name
    is_snippet? ? object.cover : object.splash
  end

  def cover_prefix
    is_snippet? ? COVER_PREFIXES[:snippet] : COVER_PREFIXES[:collection]
  end

  def cover_sizes
    is_snippet? ? COVER_SIZES[:snippet] : COVER_SIZES[:collection]
  end

  def cover_suffix
    is_snippet? ? COVER_SUFFIX[:snippet] : COVER_SUFFIX[:collection]
  end
end
