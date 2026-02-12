# frozen_string_literal: true

require "httparty"

module OpenLibrary
  class SearchService
    BASE_URL = "https://openlibrary.org/search.json"
    DEFAULT_LIMIT = 10

    def initialize(query:, limit: DEFAULT_LIMIT)
      @query = query.to_s.strip
      @limit = limit.to_i
    end

    def call
      return [] if @query.blank?

      response = HTTParty.get(
        BASE_URL,
        query: {
          q: @query,
          limit: @limit
        },
        headers: {
          "Accept" => "application/json"
        },
        timeout: 8
      )

      return [] unless response.success?

      parse_response(response.parsed_response)
    rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error
      []
    rescue StandardError
      []
    end

    private

    def parse_response(parsed)
      docs = parsed.is_a?(Hash) ? parsed["docs"] : nil
      return [] unless docs.is_a?(Array)

      docs.first(@limit).map { |doc| normalize_doc(doc) }.compact
    end

    def normalize_doc(doc)
      return nil unless doc.is_a?(Hash)

      title = doc["title"].to_s.strip
      author = Array(doc["author_name"]).first.to_s.strip
      published_year = Array(doc["first_publish_year"]).first
      isbn = Array(doc["isbn"]).first.to_s.strip
      cover_id = doc["cover_i"]

      return nil if title.blank?

      {
        title: title,
        author: author.presence,
        published_year: published_year,
        isbn: isbn.presence,
        image_url: cover_url(cover_id)
      }
    end

    def cover_url(cover_id)
      return nil if cover_id.blank?

      "https://covers.openlibrary.org/b/id/#{cover_id}-M.jpg"
    end
  end
end
