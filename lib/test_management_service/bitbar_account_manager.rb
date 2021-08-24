# frozen_string_literal: true

require 'json'
require 'time'

module TestManagementService
  class BitbarAccountManager

    DEFAULT_FILE_LOCATION = 'cached_accounts'

    def initialize(max_accounts, timeout = 3600)
      @lock = Mutex.new
      previous_accounts = read_cached_state || []
      @accounts = (1..max_accounts).map do |index|
        previous_account = previous_accounts.find { |account| account[:id] == index }
        if previous_account
          unless previous_account[:expiry].nil?
            previous_account[:expiry] = Time.parse(previous_account[:expiry])
          end
          previous_account
        else
          {
            id: index,
            claimed: false,
            expiry: nil
          }
        end
      end
      @timeout = timeout
    end

    def refresh_accounts
      current_time = Time.now
      @accounts.each do |account|
        next unless account[:claimed]

        if current_time >= account[:expiry]
          account[:claimed] = false
          account[:expiry] = nil
        end
      end
    end

    def claim_account
      @lock.synchronize do
        refresh_accounts
        open_account = @accounts.find { |account| !account[:claimed] }
        return nil if open_account.nil?
        expiry_time = Time.new + @timeout
        open_account[:claimed] = true
        open_account[:expiry] = expiry_time
        cache_state(@accounts)
        open_account
      end
    end

    def release_account(id)
      @lock.synchronize do
        refresh_accounts
        claimed_account = @accounts.find { |account| account[:id] == id }
        claimed_account[:claimed] = false
        claimed_account[:expiry] = nil
        cache_state(@accounts)
      end
    end

    def cache_state(state)
      File.open(DEFAULT_FILE_LOCATION, 'w') do |f|
        f.write JSON.dump(state)
      end
    end

    def read_cached_state
      return nil unless File.exists? DEFAULT_FILE_LOCATION
      File.open(DEFAULT_FILE_LOCATION, 'r') do |f|
        JSON.parse(f.read, {symbolize_names: true})
      end
    end
  end
end
