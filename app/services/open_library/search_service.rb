# app/services/open_library/search_service.rb
require "net/http"
require "json"

module OpenLibrary
  class SearchService
    BASE_URL = "https://openlibrary.org/search.json"

    def initialize(query:)
      @query = query
    end

    def call
      return [] if @query.blank?
      
      uri = URI("#{BASE_URL}?q=#{URI.encode_www_form_component(@query)}&limit=5")
      response = Net::HTTP.get(uri)
      parse_response(JSON.parse(response))
    rescue StandardError
      []
    end

    private

    def parse_response(body)
      body.fetch("docs", []).map do |doc|
        {
          title: doc["title"],
          author: doc["author_name"]&.first,
          published_year: doc["first_publish_year"],
          isbn: doc["isbn"]&.first,
          image_url: doc["cover_i"] ? "https://covers.openlibrary.org/b/id/#{doc["cover_i"]}-M.jpg" : nil
        }
      end
    end
  end
end