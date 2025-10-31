#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rufus-scheduler'
require_relative '../infrastructure/config/database'
require_relative '../infrastructure/workers/relay_outbox_worker'

Facturas::Infrastructure::Config::Database.establish_connection

scheduler = Rufus::Scheduler.new

puts "🚀 Iniciando Relay Runner (Outbox) — #{Time.now.utc}"

scheduler.every '30s' do
  begin
    puts "⏱️ Procesando eventos pendientes — #{Time.now.utc}"
    Facturas::Infrastructure::Workers::RelayOutboxWorker.new.perform
  rescue StandardError => e
    warn "[ERROR] Relay Runner: #{e.message}"
  end
end

scheduler.join
