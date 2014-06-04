#!/usr/bin/ruby
require 'twitter'
require 'pit'

ENV['EDITOR'] ||= 'vim'
config = Pit.get('Twitter OAuth Token', :require => { 'consumer_key' => 'Your Consumer Key', 'consumer_secret'  => 'Your Consumer Secret', 'access_token' => 'Your Access Token', 'access_token_secret' => 'Your Access Token Secret', 'screen_name' => 'Your Screen Name', 'list_slug' => 'Target List Slug'})

CONSUMER_KEY 		= config['consumer_key']
CONSUMER_SECRET 	= config['consumer_secret']
ACCESS_TOKEN 		= config['access_token']
ACCESS_TOKEN_SECRET = config['access_token_secret']

LIST_OWNER_SCREEN_NAME 	= config['screen_name']
LIST_SLUG				= config['list_slug']

def expand_url(url, limit = 5)
	begin
		uri = url.kind_of?(URI) ? url : URI.parse(url)
		Net::HTTP.start(uri.host, uri.port) { |io|
			response = io.head(uri.path)
			case response
			when Net::HTTPSuccess
				response['Location'] || uri.to_s
			when Net::HTTPRedirection
				if limit > 1 then
					expand_url(response['Location'], limit -1)
				else
					response['Location'] || uri.to_s
				end
			else
				url
			end
		}
	rescue
		url
	end
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end

list = client.list(LIST_OWNER_SCREEN_NAME, LIST_SLUG)

members = client.list_members(list,{})

print("********** ", LIST_OWNER_SCREEN_NAME, "/", LIST_SLUG, " **********\n\n")
members.each { |i|
	print(i.screen_name, ", ", i.name, ", ", expand_url(i.website, 1), "\n")
}
