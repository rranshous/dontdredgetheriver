#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'sinatra'
require 'thread'



class Gallery < Array
  attr_reader :max_length
  def initialize max_length=100, data=[]
    super data
    self.max_length = max_length
    @lock = Mutex.new
    cull
  end

  def add to_add
    puts "adding: #{to_add.length}"
    @lock.synchronize do
      self.concat to_add
      self.uniq!
      cull
    end
    to_add
  end

  private
  attr_writer :max_length

  def cull
    self[0..-1] = self[[self.length-100, 0].max..-1] || []
  end
end

gallery = Gallery.new(50)

def new_gallery_data
  puts "getting new gallery data"
  gallery_data = open('http://imgur.com/gallery.json').read
  JSON.parse(gallery_data)['data']
    .select {|i| i['ext'] == '.gif'}
    .map {|i| i['url'] = "http://imgur.com/#{i['hash']}#{i['ext']}" }
end

def update_gallery_data(gallery)
  gallery.add new_gallery_data
  puts "new gallery data: #{gallery.length}"
end

def random_image_url(gallery)
  gallery.sample.tap do |url|
    puts "random url: #{url}"
  end
end

Thread.abort_on_exception = true
Thread.new do
  loop do
    puts "replacing gallery data"
    update_gallery_data(gallery)
    puts "sleeping replacer"
    sleep 10
  end
end



get '/' do
"""
<b>SEE WHAT YOU DID?!</b>
<br>
<html><body><img src='#{random_image_url(gallery)}'/></body></html>
"""
end

get '/data' do
  gallery.to_json
end
