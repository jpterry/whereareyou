#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "eventmachine"
require "em-websocket"
require 'uuidtools'
require 'sinatra/base'
require 'thin'
require 'json'

class Stream
  attr_reader :stream_id, :sender, :listeners
  def initialize
    @stream_id = UUIDTools::UUID.random_create.to_s
    @sender = nil
    @listeners = []
  end
end

class App < Sinatra::Base
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end
end

EM.run do
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do
      puts "WebSocket connection open"
      ws.send({ :streamId => UUIDTools::UUID.random_create.to_s }.to_json)
    end

    ws.onclose { puts "Connection closed" }
    ws.onmessage { |msg|
      puts "Recieved message: #{msg}"

      #ws.send "Pong: #{msg}"
    }

  end

Thin::Server.start App, '0.0.0.0', 4000
end

