#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "eventmachine"
require "em-websocket"
require 'uuidtools'
require 'sinatra/base'
require 'thin'
require 'json'
require 'logger'

$logger = Logger.new(File.expand_path('../log/server.log', __FILE__))
def log_info(msg)
  $logger.info(msg)
end

class Stream
  attr_reader :stream_id, :sender, :listeners, :channel

  def initialize(web_socket)
    @stream_id = UUIDTools::UUID.random_create.to_s
    @sender = nil
    @listeners = []

    @channel = EM::Channel.new
  end
end


class App < Sinatra::Base
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  get '/view/new' do
    id = UUIDTools::UUID.random_create.to_s
    redirect("/view/#{id}")
  end

  get 'view/:id' do |id|
    "hey"
  end

end


@streams = Set.new

EM.run do
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do
      @streams << Stream.new(ws)
      case ws.request['path']
      when '/view'
        puts "viewer"
        @streams.each { |str| str.channel.subscribe{ |msg| ws.send(msg) } }
        ws.send("you're a viewer")

      when '/send'
        puts "sender"

        ws.onmessage do |msg|
          @streams.each{|str| str.channel.push(msg)}
        end
        ws.send("you're a sender")

      else
        puts "unknown socket"
      end

      log_info "WebSocket connection open #{ws.inspect}"
      # ws.send({ :streamId => UUIDTools::UUID.random_create.to_s }.to_json)
    end

    # ws.onclose { log_info "Connection closed" }
    # ws.onmessage { |msg|
    #   log_info "Recieved message: #{msg}"
    # }

  end

Thin::Server.start App, '0.0.0.0', 4000
end

