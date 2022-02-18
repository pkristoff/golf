# frozen_string_literal: true

require 'rails_helper'
require 'common/account_common'

describe 'accounts/edit.html.erb', type: :view do
  include AccountCommon
  it 'basic edit' do
    account = FactoryBot.create(:account)
    assign(:account, account)
    assign(:calc_hix_rounds, [])

    render

    AccountCommon.expect_edit_account(
      rendered,
      account,
      { account_name: 'Paul',
        handicap_index: 0.0 }
    )
  end
end
