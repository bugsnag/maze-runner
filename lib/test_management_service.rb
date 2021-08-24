# frozen_string_literal: true

require_relative 'test_management_service/bitbar_account_manager'
require_relative 'test_management_service/server'

server = WEBrick::HTTPServer.new(:Port => 1234)

server.mount "/account",
             TestManagementService::AccountServlet,
             TestManagementService.BitbarAccountManager.new(10)

server.start