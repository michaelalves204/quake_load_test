# frozen_string_literal: true

require_relative 'client/request'
require 'logger'
require 'concurrent'

# This class is responsible for performing multiple HTTP requests concurrently
# and collecting metrics about their execution.
class Quake
  TOTAL_EXECUTION_TEXT = 'total execution time of '

  def initialize(
    requests,
    url,
    type,
    headers = nil,
    data = nil
  )
    @url = url
    @headers = headers
    @type = type.downcase
    @data = data
    @requests = requests
    @min_threads = 10
    @max_threads = 100
    @queue = requests
  end

  def call
    start_time = Time.now
    @status_response = []
    @time_for_requests = []

    execute_requests

    executor.shutdown
    executor.wait_for_termination

    finish_time = Time.now - start_time

    metrics(finish_time)
  end

  private

  def execute_requests
    @requests.times do
      executor.post do
        first_time = Time.now

        logger.info client

        @time_for_requests.push(Time.now - first_time)

        status_response.push(client[:status])
      rescue StandardError
        executor.shutdown
      end
    end
  end

  def executor
    @executor ||= Concurrent::ThreadPoolExecutor.new(
      min_threads:,
      max_threads:,
      max_queue: queue
    )
  end

  def client
    @client ||= Client::Request.new(url, type, headers, data).start
  rescue StandardError => e
    raise e
  end

  def logger
    Logger.new($stdout)
  end

  def metrics(finish_time)
    logger.info "#{TOTAL_EXECUTION_TEXT} #{requests} requests #{finish_time}"
    logger.info segment_request_status
    logger.info "average: #{average} faster: #{faster} slower: #{slower}"
  end

  def segment_request_status
    status_count = Hash.new(0)

    status_response.each do |status|
      status_count[status] += 1
    end

    status_count.each do |status, count|
      logger.info "#{count} requests with #{status} status"
    end
  end

  def average
    sum = 0

    @time_for_requests.each { |time| sum += time }

    sum / requests
  end

  def faster
    @time_for_requests.min
  end

  def slower
    @time_for_requests.max
  end

  attr_reader :requests, :min_threads, :max_threads, :queue, :url,
              :headers, :type, :data, :status_response, :request_times
end
