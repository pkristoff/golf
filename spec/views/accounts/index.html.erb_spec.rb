# frozen_string_literal: true

require 'rails_helper'
require 'common/account_common'

RSpec.describe 'accounts/index.html.erb', type: :view do
  include AccountCommon
  it 'index with zero accounts' do
    assign(:accounts, [])

    render

    AccountCommon.expect_index_account(rendered, [])
  end

  it 'index with one course' do
    account = FactoryBot.create(:account)
    assign(:accounts, [account])

    render

    AccountCommon.expect_index_account(rendered, [account])
  end
end
