# frozen_string_literal: true

module ButtonToCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders

    # expect other buttons
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:course_names</tt> Array o button names
    # * <tt>:round_names</tt> Array o button names
    #
    def expect_other_buttons(rendered_or_page, course_names, round_names)
      expect_button_within_course_fieldset(rendered_or_page, course_names)
      expect_button_within_round_fieldset(rendered_or_page, round_names)
    end

    # expect a sidebar button
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:button_name</tt> button name
    #
    def expect_side_bar_button(rendered_or_page, button_name)
      fieldset_form_txt = 'aside[id=aside] ul[id=sidebar] li[class=nav-item] form[class=button_to] '
      expect_submit_button(rendered_or_page, fieldset_form_txt, false, button_name)
    end

    # expect a no sidebar button
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:button_name</tt> button name
    #
    def expect_no_side_bar_button(rendered_or_page, button_name)
      expect_no_submit_button(rendered_or_page, button_name)
    end

    # expect a submit button
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:fieldset_form_txt</tt> location in html
    # * <tt>:disabled</tt> button should disables
    # * <tt>:button_name</tt> button name
    #
    def expect_submit_button(rendered_or_page, fieldset_form_txt, disabled, button_name)
      disabled_txt = ''
      disabled_txt = '[disabled = disabled]' if disabled
      # rubocop:disable Layout/LineLength
      # Make sure button exists
      expect(rendered_or_page).to have_selector("input[type=submit][value='#{button_name}']", count: 1)
      # then with form inside the edit fieldset.
      expect(rendered_or_page).to have_selector("#{fieldset_form_txt} input[type=submit]#{disabled_txt}[value='#{button_name}']", count: 1)
      # rubocop:enable Layout/LineLength
    end

    # expect no submit button
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:button_name</tt> button name
    #
    def expect_no_submit_button(rendered_or_page, button_name)
      expect(rendered_or_page).not_to have_selector("input[type=submit][value='#{button_name}']", count: 1)
    end

    private

    def expect_button_within_round_fieldset(rendered_or_page, names)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Round::ROUND_BUTTONS)
      expect_button_count(rendered_or_page, 'round-div', names.size)
      names.each do |name|
        expect_button_to(rendered_or_page, 'round-div', name)
      end
    end

    def expect_button_within_course_fieldset(rendered_or_page, names)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Course::COURSE_BUTTONS)
      expect_button_count(rendered_or_page, 'course-div', names.size)
      names.each do |name|
        expect_button_to(rendered_or_page, 'course-div', name)
      end
    end

    def expect_button_count(rendered_or_page, div_id, num)
      expect(rendered_or_page).to have_selector(button_count_selector(div_id), count: num)
    end

    def button_count_selector(id)
      "div[id=#{id}][class=fieldset-button-div] form[class=button_to] input[type=submit]"
    end

    def expect_button_to(rendered_or_page, div_id, name)
      # rubocop:disable Layout/LineLength
      expect(rendered_or_page).to have_selector("div[id=#{div_id}][class=fieldset-button-div] form[class=button_to] input[type=submit][value='#{name}']", count: 1)
      # rubocop:enable Layout/LineLength
    end
  end
end
