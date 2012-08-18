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
      log_info "WebSocket connection open #{ws.inspect}"
      ws.send({ :streamId => UUIDTools::UUID.random_create.to_s }.to_json)
    end

    ws.onclose { log_info "Connection closed" }
    ws.onmessage { |msg|
      log_info "Recieved message: #{msg}"
    }

  end

Thin::Server.start App, '0.0.0.0', 4000
end

