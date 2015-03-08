require './alchemyapi'
require 'sinatra'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'httparty'
require 'uri'

get "/" do
	erb :landing
end


post "/search" do	

  	# Pass the search params into variable name
	name = URI.encode(params[:name])
	# other_name = (params[:name])
	
	# Nogogiri Gem fetches Google Search Results passed into the q parameter
	page = open "http://www.google.com/search?q=restaurant+review+#{name}"
	@html = Nokogiri::HTML page

	# Create empty array called results
	results = []
	#Pass the returned search result urls into an array called results
	# Might need to replace cite with h3 a to get the full "http://..." web url version
	@html.search("cite").each do |cite| 
		results << cite.inner_text 
	end 

	# doc = Nokogiri::HTML(open("[insert URL here]"))
	# href = doc.css('#block a')[0]["href"]

	# @href = @html.css("#search h3 a")[5]["href"].gsub("/")


	# loop through the hrefs and put them into a single array
	# break it up
	@hrefs = []
	  @hrefs << @html.css('#res h3 a')[0]["href"].gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[1].attr("href").gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[2].attr("href").gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[3].attr("href").gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[4].attr("href").gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[5].attr("href").gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[6]["href"].gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[7]["href"].gsub("/url?q=","").gsub(/&sa(.*)/,"")
	  @hrefs << @html.css('#res h3 a')[8]["href"].gsub("/url?q=","").gsub(/&sa(.*)/,"")


	# @test_href = @html.css('#ires a')[0].attr("href").gsub("/url?q=","").gsub(/&sa(.*)/,"")
	# @hrefs << @test_href


	#Delete certain results from the array if they match words like "yelp", etc.
	# do multiple strips for each offending phrase, urbanspoon, menupages, tripadvisor
	results_pass_one = results.delete_if {|x| x =~ /yelp/ }
	results_pass_two = results_pass_one.delete_if {|x| x =~ /urbanspoon/ }
	results_pass_three = results_pass_two.delete_if {|x| x =~ /menupages/}
	results_pass_four = results_pass_three.delete_if {|x| x =~ /tripadvisor/}
	results_pass_five = results_pass_four.delete_if {|x| x =~ /https/}
	@results = results_pass_five

	# Take the results array
	result_group = []
	@results.each do |r|
		result_group << "http://" + r.gsub(" ", "")
		@result_group = result_group
	end

	# Pass the result group array into the Readability API call and then pass those into another array


	# Pass the Results Array into an Object for inserting into the Readability API
	@result_one = @results[0]
	@result_one = "http://" + @result_one.gsub(" ", "")
	# remove trailing space between characters
	# @result_one = @result_one.gsub(" ", "")
	url = URI.encode(@result_one)


	# Readability Parser API token
	parser_key_token = "e7bc27e0bdf47322e153753e80eb446381184dba"
	# reader_key = "3LZmAnWTrJjnb5ajDZJJVsKnqCXnFC6P"
    # URL to pass into the Readability Parser API call
	# url = "http://www.laweekly.com/restaurants/alimento-review-italian-by-way-of-california-in-silver-lake-5079800"
	# @test_read = "http://www.readability.com/api/content/v1/parser?url=#{@url}/&token=#{parser_key_token}"
	#HTTParty grabs the parsed content for the url from the Readability API which breaks it into pieces like title, content, author
	@document_results = HTTParty.get("http://www.readability.com/api/content/v1/parser?url=#{url}/&token=#{parser_key_token}")
	# Grabs the content from the Readbility API call
	# excerpt
	@excerpt = @document_results['excerpt']
	#title, 
	@title = @document_results['title']
	#lead_image_url, 
	@lead_image = @document_results['lead_image_url']
	#author,
	@author = @document_results['author']
	#date_published, 
	@date_published = @document_results['date_published']
	#url, 
	@url = @document_results['url']
	#full page content
	content = @document_results['content']

	@content = Nokogiri::HTML.parse(content).css('p')[2].text

	# Alchemy API key
	# alchemy_api_key = '6d4da82dec83a3c1286f549a203900396a0341a5'
	# HTML document must be URI encoded, else use the URL, and need to be made with POST
	# @sentiment_results = HTTParty.get("http://access.alchemyapi.com/calls/url/URLGetTargetedSentiment?apikey=#{alchemy_api_key}&target=#{name}&url=#{url}&outputMode=json")
	# "http://access.alchemyapi.com/calls/url/URLGetTargetedSentiment?apikey=#{alchemy_api_key}&target=#{name}&url=#{url}&outputMode=json"
	# @sentiment_results = HTTParty.get("http://access.alchemyapi.com/calls/url/URLGetTargetedSentiment?apikey=6d4da82dec83a3c1286f549a203900396a0341a5&target=Alimento&url=http://www.laweekly.com/restaurants/alimento-review-italian-by-way-of-california-in-silver-lake-5079800&outputMode=json")
	# sentiment_results = HTTParty.get("http://access.alchemyapi.com/calls/url/URLGetTargetedSentiment?apikey=6d4da82dec83a3c1286f549a203900396a0341a5&target=google&url=http://www.google.com&outputMode=json")
	# @sentiment_results = sentiment_results['results']['url']


	# demo_text = 'Yesterday dumb Bob destroyed my fancy iPhone in beautiful Denver, Colorado. I guess I will have to head over to the Apple Store and buy a new one.'
	# demo_url = "http://www.laweekly.com/restaurants/alimento-review-italian-by-way-of-california-in-silver-lake-5079800"
	# demo_html = '<html><head><title>Python Demo | alchemyapi</title></head><body><h1>Did you know that alchemyapi works on HTML?</h1><p>Well, you do now.</p></body></html>'
	# text = @document_results['content']

	# url_one = "http://www.lamag.com/digestblog/kuh-review-alimento/"
	# url_two ="http://www.latimes.com/food/la-fo-gold-alimento-20141011-story.html"
	# url_three = "http://www.timeout.com/los-angeles/restaurants/alimento"

	alchemyapi = AlchemyAPI.new()

	response = alchemyapi.sentiment_targeted('url', @url, (params[:name]))
	@sentiment_results = response

	@type = response['docSentiment']['type']
	score = response['docSentiment']['score']
	@score = score.to_f * 100


	erb :index

end


get "/show" do

	# @urls = ["http://www.lamag.com/digestblog/kuh-review-alimento/", "http://www.latimes.com/food/la-fo-gold-alimento-20141011-story.html", "http://www.timeout.com/los-angeles/restaurants/alimento"]
	url_one = "http://www.lamag.com/digestblog/kuh-review-alimento/"
	url_two = "http://www.latimes.com/food/la-fo-gold-alimento-20141011-story.html"
	url_three = "http://www.timeout.com/los-angeles/restaurants/alimento"

	alchemyapi = AlchemyAPI.new()

    # response one
	response = alchemyapi.sentiment_targeted('url', url_one, 'Alimento')
	@sentiment_results = response

	@type = response['docSentiment']['type']
	score = response['docSentiment']['score']
	@score = score.to_f * 100

	# response two

	response_two = alchemyapi.sentiment_targeted('url', url_two, 'Alimento')
	@sentiment_results_two = response_two

	@type_two = response_two['docSentiment']['type']
	score_two = response_two['docSentiment']['score']
	@score_two = score_two.to_f * 100

	# response three

	response_three = alchemyapi.sentiment_targeted('url', url_three, 'Alimento')
	@sentiment_results_three = response_three

	@type_three = response_three['docSentiment']['type']
	score_three = response_three['docSentiment']['score']
	@score_three = score_three.to_f * 100

	# @urls.each do |i|
	# 	collection = alchemyapi.sentiment_targeted('url', i, 'Alimento')
	# end

	# @response = collection


	erb :show

end
