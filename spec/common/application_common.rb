# frozen_string_literal: true

module AsideCommon
  def expect_aside(page_or_rendered)
    # rubocop:disable Layout/LineLength
    expect(page_or_rendered).to have_selector("aside[id=aside] form[class=button_to] input[type=submit][value='#{Button::Course::SHOW_COURSES}']",
                                              count: 1)
    expect(page_or_rendered).to have_selector("aside[id=aside] form[class=button_to] input[type=submit][value='#{Button::Round::COURSES}']",
                                              count: 1)
    # rubocop:enable Layout/LineLength

    expect(page_or_rendered).to have_button(Button::Course::SHOW_COURSES, count: 1)
    expect(page_or_rendered).to have_button(Button::Round::COURSES, count: 1)
  end
end
