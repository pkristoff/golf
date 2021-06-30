# frozen_string_literal: true

module ButtonToCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders

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

    private

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
