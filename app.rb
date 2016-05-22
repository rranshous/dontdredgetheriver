#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'sinatra'
require 'thread'

gallery_lock = Mutex.new
gallery = []

update_gallery_data = lambda do
  puts "getting new gallery data"
  gallery_data = open('http://imgur.com/gallery.json').read
  new_data = JSON.parse(gallery_data)['data']
    .select {|i| i['ext'] == '.gif'}
    .map {|i| i['url'] = "http://imgur.com/#{i['hash']}#{i['ext']}" }
  gallery_lock.synchronize {
    gallery += new_data.uniq.sample(100)
    puts "new gallery data: #{gallery.length}"
  }
end

random_image_url = lambda do
  url = gallery_lock.synchronize { gallery.sample }
  puts "random url: #{url}"
  url
end

update_gallery = lambda do
  loop do
    puts "replacing gallery data"
    update_gallery_data.call
    puts "sleeping replacer"
    sleep 10
  end
end

Thread.abort_on_exception = true
Thread.new(&update_gallery)


get '/' do
"""
<b>SEE WHAT YOU DID?!</b>
<br>
<html><body><img src='#{random_image_url.call}'/></body></html>
"""
end

get '/data' do
  gallery.to_json
end
