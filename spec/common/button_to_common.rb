# frozen_string_literal: true

module ButtonToCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    def expect_button_within_round_fieldset(page_or_rendered, names)
      expect(page_or_rendered).to have_selector('fieldset', count: 1, text: Fieldset::Round::ROUND_BUTTONS)
      ButtonToCommon.expect_button_count(page_or_rendered, 'round-div', names.size)
    end

    def expect_button_within_course_fieldset(page_or_rendered, names)
      expect(page_or_rendered).to have_selector('fieldset', count: 1, text: Fieldset::Course::COURSE_BUTTONS)
      ButtonToCommon.expect_button_count(page_or_rendered, 'course-div', names.size)
      names.each do |name|
        ButtonToCommon.expect_button_to(page_or_rendered, 'course-div', name)
      end
    end

    def expect_button_count(page_or_rendered, div_id, num)
      # rubocop:disable Layout/LineLength
      expect(page_or_rendered).to have_selector("div[id=#{div_id}][class=fieldset-button-div] form[class=button_to] input[type=submit]", count: num)
      # rubocop:enable Layout/LineLength
    end

    def expect_button_to(page_or_rendered, div_id, name)
      # rubocop:disable Layout/LineLength
      expect(page_or_rendered).to have_selector("div[id=#{div_id}][class=fieldset-button-div] form[class=button_to] input[type=submit][value='#{name}']", count: 1)
      # rubocop:enable Layout/LineLength
    end
  end
end
