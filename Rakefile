# frozen_string_literal: true

require_relative 'lib/quake'

desc 'Make requests to a Rest API'
task :execute_quake, [:requests, :url, :type, :data, :headers] do |_t, args|
  requests = args[:requests].to_i || 10
  url = args[:url]
  type = args[:type] || 'get'
  headers = args[:headers] || nil
  data = args[:data] || nil

  Quake.new(requests, url, type, headers, data).call
end
