require './alchemyapi'

demo_text = 'Yesterday dumb Bob destroyed my fancy iPhone in beautiful Denver, Colorado. I guess I will have to head over to the Apple Store and buy a new one.'
demo_url = "http://www.laweekly.com/restaurants/alimento-review-italian-by-way-of-california-in-silver-lake-5079800"
demo_html = '<html><head><title>Python Demo | alchemyapi</title></head><body><h1>Did you know that alchemyapi works on HTML?</h1><p>Well, you do now.</p></body></html>'

alchemyapi = AlchemyAPI.new()

response = alchemyapi.sentiment_targeted('url', demo_url, 'Alimento')

if response['status'] == 'OK'
	puts '## Response Object ##'
	puts JSON.pretty_generate(response)


	puts ''
	puts '## Targeted Sentiment ##'
	puts 'type: ' + response['docSentiment']['type']
	
	#Make sure score exists (it's not returned for neutral sentiment
	if response['docSentiment'].key?('score')
		puts 'score: ' + response['docSentiment']['score']
	end

else
	puts 'Error in targeted sentiment analysis call: ' + response['statusInfo']
end
