require 'json'
require 'tzinfo'
require 'logger'
require 'uri'

def logger
  @logger ||= Logger.new($stdout, level: Logger::Severity::INFO)
end

def create_local_time(time_str, zone_abbreviation)
  time = Time.parse(time_str)

  zone = TZInfo::Timezone.all.find { _1.abbreviation == zone_abbreviation }
  raise "Timezone not found: #{zone_abbreviation}" if zone.nil?

  time.localtime(zone.observed_utc_offset).iso8601
rescue ArgumentError
  raise "Invalid time format: #{time_str}"
end

def lambda_handler(event:, context:)
  logger.debug(event)
  logger.debug(context)

  params = URI.decode_www_form(event['body']).to_h
  body = create_local_time(*params['text'].split(',').map(&:strip))

  { statusCode: 200, body: }
rescue StandardError => e
  logger.fatal(e.full_message)
  { statusCode: 200, body: e.message }
end
