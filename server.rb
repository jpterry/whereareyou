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
require 'securerandom'

$logger = Logger.new(File.expand_path('../log/server.log', __FILE__))
def log_info(msg)
  $logger.info(msg)
end

class LocationStream
  attr_reader :stream_id, :sender, :listeners, :channel

  def initialize(ws=nil)
    @stream_id = UUIDTools::UUID.random_create.to_s
    @sender = nil
    @listeners = []

    @channel = EM::Channel.new
  end

end


class App < Sinatra::Base

  def self.streams
    (@streams ||= {})
  end

  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  get '/view/new' do
    s = LocationStream.new
    self.class.streams[s.stream_id] = s
    redirect("/view/#{s.stream_id}")
  end

  get '/view/:id' do |id|
    trk_link = "http://#{request.host}:4000/send/#{id}"

    erb :recv, :locals => {:stream => self.class.streams[id], :tracking_link => trk_link}
  end

  get '/send/:id' do |id|
    erb :send, :locals => {:stream => self.class.streams[id]}
  end

end

EM.run do
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do
      case ws.request['path']
      when %r{/view}
        if(stream = App.streams[ws.request["query"]["stream_id"]])
          stream.channel.subscribe{ |msg| ws.send(msg) }
          ws.send("connected")
        else
          puts "socket not found"
        end

      when %r{/send}
        if(stream = App.streams[ws.request["query"]["stream_id"]])
          ws.onmessage do |msg|
            stream.channel.push(msg)
          end
          ws.send("you're a sender")
        else
          puts "send socket not found"
        end

      else
        log_info "unknown socket path"
      end

      log_info "WebSocket connection open #{ws.inspect}"
    end

    # ws.onclose { log_info "Connection closed" }
    # ws.onmessage { |msg|
    #   log_info "Recieved message: #{msg}"
    # }

  end

Thin::Server.start App, '0.0.0.0', 4000
end

