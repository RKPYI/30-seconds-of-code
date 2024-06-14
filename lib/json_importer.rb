class JsonImporter
  attr_reader :json

  CONTENT_JSON_PATH = './.content/content.json'

  # rake db:migrate:reset; rake import:content
  def initialize
    @json = nil
  end

  def read_file
    file = File.read(CONTENT_JSON_PATH)
    @json = JSON.parse(file).deep_symbolize_keys

    nil
  end

  def import
    read_file
    import_languages
    import_collections
    import_snippets
    import_collections_snippets
  end

  def import_languages
    @json[:languages].each do |language|
      Language.create({
        cid: language[:id],
        long: language[:long],
        short: language[:short],
        name: language[:name]
      })
    end

    nil
  end

  def import_collections
    @json[:collections].each do |collection|
      Collection.create({
        cid: collection[:id],
        name: collection[:name],
        short_name: collection[:shortName],
        mini_name: collection[:miniName],
        slug: collection[:slug],
        featured: collection[:featured],
        featured_index: collection[:featuredIndex],
        splash: collection[:splash],
        description: collection[:description],
        short_description: collection[:shortDescription],
        seo_description: collection[:seoDescription],
        top_level: collection[:topLevel],
        allow_unlisted: collection[:allowUnlisted],
        parent_cid: collection[:parent]
      })
    end

    nil
  end

  def import_snippets
    @json[:snippets].each do |snippet|
      Snippet.create({
        cid: snippet[:id],
        file_name: snippet[:fileName],
        title: snippet[:title],
        _tags: snippet[:tags].join(';'),
        short_title: snippet[:shortTitle],
        date_modified: snippet[:dateModified],
        listed: snippet[:listed],
        ctype: snippet[:type],
        short_text: snippet[:shortText],
        full_text: snippet[:fullText],
        description_html: snippet[:descriptionHtml],
        full_description_html: snippet[:fullDescriptionHtml],
        cover: snippet[:cover],
        seo_description: snippet[:seoDescription],
        language_cid: snippet[:language]
      })
    end

    nil
  end

  def import_collections_snippets
    @json[:collections].each do |collection|
      collection_record = Collection.find(collection[:id])
      if collection[:snippetIds].present?
        snippet_records = Snippet.where(cid: collection[:snippetIds])
        collection_record.snippets = snippet_records
      end
      # TODO: Work on matchers here
    end

    nil
  end
end
