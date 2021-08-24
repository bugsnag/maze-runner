# frozen_string_literal: true

require_relative 'test_management_service/bitbar_account_manager'
require_relative 'test_management_service/server'

ACCOUNT_MAXIMUM = ENV['BITBAR_ACCOUNT_MAX'].to_i

server = WEBrick::HTTPServer.new(:Port => 9340)

server.mount "/account",
             TestManagementService::AccountServlet,
             TestManagementService::BitbarAccountManager.new(ACCOUNT_MAXIMUM)

server.start