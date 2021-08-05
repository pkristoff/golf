# frozen_string_literal: true

module AsideCommon
  class << self
    include RSpec::Matchers
    # enable_expect
    def expect_aside(rendered_or_page, show_tees)
      raise('show_round_tees not set') if show_tees.nil?
      raise('show_course_tees not set') if show_tees.nil?

      ButtonToCommon.expect_side_bar_button(rendered_or_page, Button::Course::SHOW_COURSES)
      ButtonToCommon.expect_side_bar_button(rendered_or_page, Button::Round::COURSES)
      ButtonToCommon.expect_side_bar_button(rendered_or_page, Button::Round::TEES) if show_tees
      ButtonToCommon.expect_no_side_bar_button(rendered_or_page, Button::Round::TEES) unless show_tees
    end
  end
end

module DatabaseCommon
  class << self
    include RSpec::Matchers

    def expect_database(rendered_or_page)
      # rubocop:disable Layout/LineLength
      expect(rendered_or_page).to have_selector('a[id=navbardrop]', text: Label::Database::DATABASE, count: 1)
      expect(rendered_or_page).to have_selector('ul[class=dropdown-menu] a[id=clear_db]', text: Label::Database::CLEAR, count: 1)
      expect(rendered_or_page).to have_selector('ul[class=dropdown-menu] a[id=load_in_xsxl_file]', text: Label::Database::LOAD_XSXL, count: 1)
      # rubocop:enable Layout/LineLength

      expect(rendered_or_page).to have_button(Button::Course::SHOW_COURSES, count: 1)
      expect(rendered_or_page).to have_button(Button::Round::COURSES, count: 1)
    end
  end
end
