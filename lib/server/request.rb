# frozen_string_literal: true

require 'net/http'
require 'logger'

module Server
  class Request
    HTTP_VERBS = %w[get post put].freeze

    def initialize(url, headers = nil, type = nil, data = nil)
      @url = URI.parse(url.to_s)
      @headers = headers
      @type = type.downcase
      @data = data
    end

    def start
      http.use_ssl = (url.scheme == 'https') if url.scheme == 'https'

      type_request

      authorization

      response = http.request(request)

      logger.info("http status: #{response.code}")
      logger.info("body: #{response.body}")
    end

    private

    def type_request
      return unless HTTP_VERBS.include?(type)

      case type
      when 'get'
        @request = Net::HTTP::Get.new(url)
      when 'post'
        @request = Net::HTTP::Post.new(url)
        request.body = data
      else
        raise "Tipo de solicitação não suportado: #{type}"
      end
    end

    def authorization
      return if headers.nil?

      request['Authorization'] = headers[:authorization]
    end

    def http
      Net::HTTP.new(url.host, url.port)
    end

    def logger
      Logger.new($stdout)
    end

    attr_reader :url, :headers, :request, :type, :data
  end
end
