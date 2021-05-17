# frozen_string_literal: true

module AsideCommon
  def expect_aside(page_or_rendered, show_tees)
    raise('show_round_tees not set') if show_tees.nil?
    raise('show_course_tees not set') if show_tees.nil?

    # rubocop:disable Layout/LineLength
    expect(page_or_rendered).to have_selector("aside[id=aside] form[class=button_to] input[type=submit][value='#{Button::Course::SHOW_COURSES}']",
                                              count: 1)
    expect(page_or_rendered).to have_selector("aside[id=aside] form[class=button_to] input[type=submit][value='#{Button::Tee::SHOW_TEES}']",
                                              count: show_tees ? 1 : 0)
    expect(page_or_rendered).to have_selector("aside[id=aside] form[class=button_to] input[type=submit][value='#{Button::Round::COURSES}']",
                                              count: 1)
    expect(page_or_rendered).to have_selector("aside[id=aside] form[class=button_to] input[type=submit][value='#{Button::Round::TEES}']",
                                              count: show_tees ? 1 : 0)
    # rubocop:enable Layout/LineLength

    expect(page_or_rendered).to have_button(Button::Course::SHOW_COURSES, count: 1)
    expect(page_or_rendered).to have_button(Button::Round::COURSES, count: 1)
    expect(page_or_rendered).to have_button(Button::Round::TEES, count: show_tees ? 1 : 0)
  end
end

module DatabaseCommon
  def expect_database(page_or_rendered)
    # rubocop:disable Layout/LineLength
    expect(page_or_rendered).to have_selector('a[id=navbardrop]', text: 'Database')
    expect(page_or_rendered).to have_selector('ul[class=dropdown-menu] a[id=clear_db]', text: Label::Database::CLEAR, count: 1)
    expect(page_or_rendered).to have_selector('ul[class=dropdown-menu] a[id=load_in_xsxl_file]', text: Label::Database::LOAD_XSXL, count: 1)
    # rubocop:enable Layout/LineLength

    expect(page_or_rendered).to have_button(Button::Course::SHOW_COURSES, count: 1)
    expect(page_or_rendered).to have_button(Button::Round::COURSES, count: 1)
  end
end
