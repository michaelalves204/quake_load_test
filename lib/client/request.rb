# frozen_string_literal: true

require 'net/http'
require 'logger'
require 'benchmark'
require 'json'

module Client
  # This class is responsible for making HTTP requests to a specified URL.
  class Request
    HTTP_VERBS = %w[get post put].freeze

    RESPONSE_STATUS_MESSAGE =
      {
        '2': 'success',
        '3': 'redirection',
        '4': 'failure',
        '5': 'server_problem'
      }.freeze

    # Initializes a new Request instance.
    # @param url [String] The URL to make the HTTP request to.
    # @param type [String] The HTTP request type (get, post, put).
    # @param headers [String, nil] Optional headers for the request.
    # @param data [String, nil] Optional data for the request body.

    def initialize(url, type, headers = nil, data = nil)
      @url = URI.parse(url.to_s)
      @headers = headers
      @type = type.downcase
      @data = data
    end

    def start
      http.use_ssl = (url.scheme == 'https') if url.scheme == 'https'

      type_request

      authorization

      request_data
    end

    private

    def request_data
      {
        code: response.code,
        status: response_status
      }
    end

    def response
      @response ||= http.request(request)
    end

    def response_status
      RESPONSE_STATUS_MESSAGE[response.code[0].to_sym]
    end

    def type_request
      return unless HTTP_VERBS.include?(type)

      case type
      when 'get'
        @request = Net::HTTP::Get.new(url)
      when 'post'
        @request = Net::HTTP::Post.new(url)
        request.body = data
      else
        raise "Non-support request type: #{type}"
      end
    end

    def authorization
      return if headers.nil?

      bearer_token = JSON.parse(headers.gsub("'", '"'))['authorization']

      request['Authorization'] = bearer_token
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
