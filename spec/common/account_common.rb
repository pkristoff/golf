# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'
require 'common/method_common'
require 'views/helpers'

# HoleCommon
#
module AccountCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include AsideCommon
    include DatabaseCommon
    include ButtonToCommon
    include MethodCommon

    # expect new hole should not be generated
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:accounts</tt> list of accounts
    #
    def expect_index_account(rendered_or_page, accounts)
      MethodCommon.expect_heading(rendered_or_page, Heading::Account::ACCOUNTS)
      expect_number_of_accounts(rendered_or_page, accounts)
      if accounts.empty?
        expect(rendered_or_page).to have_selector('h2', text: Heading::Account::NO_ACCOUNTS)
      else
        accounts.each do |account|
          expect(rendered_or_page).to have_selector("a[id='edit_link_#{account.id}']", text: account.name)
        end
      end
      expect_index_other_buttons(rendered_or_page)
    end

    # expect edit course
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:account</tt> course to be edited
    # * <tt>:values</tt> expected values
    #
    def expect_edit_account(rendered_or_page, account, values = {})
      AsideCommon.expect_aside(rendered_or_page, false) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_menu(rendered_or_page) unless rendered_or_page.is_a?(String)

      MethodCommon.expect_heading(rendered_or_page, Heading::Account::EDIT_ACCOUNT)

      expect_edit_fieldset_account(rendered_or_page, account, values)

      expect_edit_other_buttons(rendered_or_page)
    end

    private

    def expect_round_info(expected_round_info, rendered_or_page)
      rd_id = expected_round_info[:id]
      tr_id = "tr[id='tr-id-#{rd_id}']"
      expect(rendered_or_page).to have_selector(tr_id)
      course_name_text = expected_round_info[:course_name]
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=course-name-#{rd_id}]", text: course_name_text)
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=date-#{rd_id}]", text: expected_round_info[:date])
      number_of_holes_text = expected_round_info[:number_of_holes]
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=number-of-holes-#{rd_id}]", text: number_of_holes_text)
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=sd-#{rd_id}]", text: expected_round_info[:sd])
      total_score_text = expected_round_info[:total_score_differential]
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=total-score-differential-#{rd_id}]", text: total_score_text)
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=uses-#{rd_id}]", text: expected_round_info[:uses])
      course_handicap_text = expected_round_info[:course_handicap]
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=course-handicap-#{rd_id}]", text: course_handicap_text)
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=slope-#{rd_id}]", text: expected_round_info[:slope])
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=rating-#{rd_id}]", text: expected_round_info[:rating])
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=par-#{rd_id}]", text: expected_round_info[:par])
      adjusted_text = expected_round_info[:adjusted_score]
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=adjusted-score-#{rd_id}]", text: adjusted_text)
      unadjusted_text = expected_round_info[:unadjusted_score]
      expect(rendered_or_page).to have_selector("#{tr_id} td[id=unadjusted-score-#{rd_id}]", text: unadjusted_text)
    end

    def expect_edit_fieldset_account(rendered_or_page, account, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Edit::HEADING)
      # expect_edit_subheadings(rendered_or_page, values, Fieldset::Edit::SUBHEADING)
      form_txt = " form[action='/accounts/#{account.id}'] "
      fieldset_form_txt = Fieldset::Edit::EDIT + form_txt
      expect_account_values(rendered_or_page, values, false, fieldset_form_txt)

      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, false,
                                          Button::Account::SUBMIT)
      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, false,
                                          Button::Account::CALCUATE_HANDICAP_INDEX_NO_INIT)
      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, false,
                                          Button::Account::CALCUATE_HANDICAP_INDEX)
      expect_debug_info(rendered_or_page, values)
    end

    def expect_debug_info(rendered_or_page, values)
      calc_run = values[:calc_run]
      expect(rendered_or_page).to have_selector('p', text: 'No calculate handicap index') unless calc_run
      # expect(rendered_or_page).to have_selector("p[id='no-calc-run']") unless calc_run
      return unless calc_run

      ul_selector = 'ul[id=calc-run]'
      expect(rendered_or_page).to have_selector(ul_selector)
      expect(rendered_or_page).to have_selector("#{ul_selector} li[id=avg]", text: "AVG = #{values[:avg]}")
      avg_adj_text = "AVG-adjustment(#{values[:adjustment]}) = #{values[:avg_adj]}"
      expect(rendered_or_page).to have_selector("#{ul_selector} li[id=avg-adj]", text: avg_adj_text)
      expect(rendered_or_page).to have_selector("#{ul_selector} li[id=avg96]", text: "adjusted_avg * .96= #{values[:avg96]}")
      expected_round_info = values[:round]
      expect_round_info(expected_round_info, rendered_or_page) unless expected_round_info.nil?
      expected_round_info = values[:round2]
      expect_round_info(expected_round_info, rendered_or_page) unless expected_round_info.nil?
    end

    def expect_index_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [],
                                          [])
    end

    def expect_edit_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [],
                                          [])
    end

    def expect_number_of_accounts(rendered_or_page, accounts)
      expect(rendered_or_page).to have_selector("li[id='li-id']", count: accounts.size)
    end

    def expect_account_values(rendered_or_page, values, disabled, fieldset_form_txt = '')
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Account::NAME,
                                          'account_name',
                                          values[:account_name],
                                          disabled,
                                          fieldset_form_txt)
      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Account::HANDICAP_INDEX,
                                         'account_handicap_index',
                                         "'#{values[:handicap_index]}'",
                                         false, # This should bbe true
                                         fieldset_form_txt)
    end
  end
end
