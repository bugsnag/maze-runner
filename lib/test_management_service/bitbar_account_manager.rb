# frozen_string_literal: true

module TestManagementService
  class BitbarAccountManager
    def initialize(max_accounts, timeout = 3600)
      @accounts = (1..max_accounts).map do |index|
        {
          id: index,
          claimed: false,
          expiry: nil
        }
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
      refresh_accounts
      open_account = @accounts.find { |account| !account[:claimed] }
      return nil if open_account.nil?
      expiry_time = Time.new + @timeout
      open_account[:claimed] = true
      open_account[:expiry] = expiry_time
      open_account
    end

    def release_account(id)
      refresh_accounts
      claimed_account = @accounts.find { |account| account[:id] == id }
      claimed_account[:claimed] = false
      claimed_account[:expiry] = nil
    end
  end
end
