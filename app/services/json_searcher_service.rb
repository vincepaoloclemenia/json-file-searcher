class JsonSearcherService
  JSON_MIME_TYPE = 'application/json'
  VALID_QUERY_ATTRIBUTES = %i[email full_name]

  Marcel::MimeType.extend JSON_MIME_TYPE, extensions: %w[json]

  attr_reader :path, :term_matches, :parsed_json, :duplicates
  attr_accessor :query, :path, :find_duplicates

  def initialize(path: 'public/clients.json', query: {}, find_duplicates: false)
    @path = path
    @query = query
    @parsed_json = []
    @term_matches = []
    @find_duplicates = find_duplicates
    @duplicates = {}
  end

  def call
    validate_query
    read_file
    find_term_matches
    
    result
  end

  def path=(pathname)
    return if path == pathname
    @parsed_json = []
    @term_matches = []
    @path = pathname
  end

  def query=(new_query)
    return if new_query == query
    @term_matches = []
    @query = new_query
  end

  def inspect
    "#<JsonSearcherService query=#{query} path=#{path}>"
  end

  private

  def find_term_matches
    @term_matches.empty? and parsed_json.each_with_object(term_matches) do |hash, term_matches_obj|
      (duplicates[hash[:email]] ||= []) << hash if find_duplicates
      next unless query.any? { |key, value| hash[key.to_sym]&.match(/#{value}/i) }

      term_matches_obj << hash
    end
  end

  def read_file
    @parsed_json.empty? and File.open(path) do |file|
      filetype = Marcel::MimeType.for name: file.path
      raise "File is not a json '#{filetype}'" if filetype != JSON_MIME_TYPE
  
      @parsed_json = JSON.parse(file.read, symbolize_names: true)

      file.close
    end
  end

  def result
    duplicates.each { |key, values| duplicates.delete(key) unless values.many? } if find_duplicates
    return term_matches unless find_duplicates

    { duplicates:, term_matches: }
  end

  def validate_query
    raise StandardError, "Query is empty" if query.blank?
    raise StandardError, "Invalid query attributes" if query.keys.any? { |key| VALID_QUERY_ATTRIBUTES.exclude?(key.to_sym) }
  end
end