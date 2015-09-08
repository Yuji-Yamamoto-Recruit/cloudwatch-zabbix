#!/usr/bin/ruby

require 'aws-sdk'
require 'optparse'
require 'net/http'
require 'json'

params = ARGV.getopts(
  "",
  "region:",
  "service:",
  "metric:",
  "dimension_name:",
  "dimension_value:",
  "statistics:"
)

time_out = 30

access_key = ''
secret_key = ''
token = ''

# get key and token
uri = URI.parse("http://169.254.169.254/latest/meta-data/iam/security-credentials/foo")
Net::HTTP.start(uri.host,uri.port){|http|

  # create http instance
  request = Net::HTTP::Post.new(uri.path)
  http.open_timeout = time_out
  http.read_timeout = time_out

  # send
  response = http.request(request)

  # json parse
  result = JSON.parse(response.body)
  access_key = result["AccessKeyId"]
  secret_key = result["SecretAccessKey"]
  token = result["Token"]
}

exit if access_key == ''


Aws.config = {
  access_key_id: access_key,
  secret_access_key: secret_key,
  session_token: token,
  region: params['region'],
  http_proxy: "https://foo.bar:8080"
}

# send to cloud watch
cw = Aws::CloudWatch::Client.new

metric = cw.get_metric_statistics({
  namespace: "AWS/#{params['service']}",
  metric_name: params['metric'],
  dimensions: [
    {
      name: params['dimension_name'],
      value: params['dimension_value']
    }
  ],
  start_time: Time.now - 300,
  end_time: Time.now,
  period: 60,
  statistics: Array[params['statistics']]
})



last_stats = metric.datapoints.sort_by{|stat| stat[:timestamp]}.last

exit if last_stats.nil?

puts last_stats[params['statistics'].downcase.to_sym]

