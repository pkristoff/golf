# frozen_string_literal: true

require 'common/account_common'
require 'support/round_info_spec_helper'

feature 'Account editing' do
  include AccountCommon
  include RoundInfoSpecHelper
  # include ViewsHelpers
  before(:each) do
    @account = FactoryBot.create(:account)
  end

  after(:each) do
  end

  scenario 'edit account name' do
    visit edit_account_path(@account)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'Paul',
                                        handicap_index: 0.0,
                                        calc_run: false })

    fill_in Label::Account::NAME, with: 'PRK'
    click_button(Button::Account::SUBMIT)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'PRK',
                                        handicap_index: 0.0,
                                        calc_run: false })
  end

  scenario 'Calculate handicap index with no initial - 18holes' do
    round = RoundInfoSpecHelper.create_round18(0, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
    today = Time.zone.today
    visit edit_account_path(@account)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'Paul',
                                        handicap_index: 0.0,
                                        calc_run: false })

    click_button(Button::Account::CALCUATE_HANDICAP_INDEX_NO_INIT)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'Paul',
                                        handicap_index: 9.6,
                                        calc_run: true,
                                        avg: 14.1,
                                        adjustment: 4,
                                        avg_adj: 10.1,
                                        avg96: 9.6,
                                        round: {
                                          id: round.id,
                                          course_name: 'prk',
                                          number_of_holes: 18,
                                          date: today,
                                          sd: 14.1,
                                          total_score_differential: 14.1,
                                          uses: '*',
                                          course_handicap: 62.0,
                                          slope: 139,
                                          rating: 71.6,
                                          par: 71,
                                          adjusted_score: 89,
                                          unadjusted_score: 89
                                        } })
  end

  scenario 'Calculate handicap index with no initial - 9oles' do
    round1 = RoundInfoSpecHelper.create_round9(0, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 35)
    round2 = RoundInfoSpecHelper.create_round9(0, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 35)
    today = Time.zone.today
    visit edit_account_path(@account)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'Paul',
                                        handicap_index: 0.0,
                                        calc_run: false })

    click_button(Button::Account::CALCUATE_HANDICAP_INDEX_NO_INIT)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'Paul',
                                        handicap_index: 54.0,
                                        calc_run: true,
                                        avg: 75.0,
                                        adjustment: 4,
                                        avg_adj: 71.0,
                                        avg96: 68.16,
                                        round: {
                                          id: round1.id,
                                          course_name: 'prk',
                                          number_of_holes: 9,
                                          date: today,
                                          sd: 33.0,
                                          total_score_differential: 75.0,
                                          uses: '*',
                                          course_handicap: 50.0,
                                          slope: 113,
                                          rating: 35.0,
                                          par: 35,
                                          adjusted_score: 68,
                                          unadjusted_score: 68
                                        },
                                        round2: {
                                          id: round2.id,
                                          course_name: 'prk',
                                          number_of_holes: 9,
                                          date: today,
                                          sd: 42.0,
                                          total_score_differential: 75.0,
                                          uses: '*',
                                          course_handicap: 50.0,
                                          slope: 113,
                                          rating: 35.0,
                                          par: 35,
                                          adjusted_score: 77,
                                          unadjusted_score: 77
                                        } })
  end

  scenario 'Calculate handicap index with no initial - 2 9holes' do
    RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 35)
    RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 35)
    visit edit_account_path(@account)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'Paul',
                                        handicap_index: 0.0,
                                        calc_run: false })

    click_button(Button::Account::CALCUATE_HANDICAP_INDEX_NO_INIT)

    AccountCommon.expect_edit_account(page, @account,
                                      { account_name: 'Paul',
                                        handicap_index: 54.0,
                                        calc_run: true,
                                        avg: 66.0,
                                        adjustment: 4,
                                        avg_adj: 62.0,
                                        avg96: 59.51 })
  end
end
