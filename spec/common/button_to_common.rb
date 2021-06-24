# frozen_string_literal: true

module ButtonToCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders

    def expect_button_within_round_fieldset(page_or_rendered, names)
      expect(page_or_rendered).to have_selector('fieldset', count: 1, text: Fieldset::Round::ROUND_BUTTONS)
      expect_button_count(page_or_rendered, 'round-div', names.size)
      names.each do |name|
        expect_button_to(page_or_rendered, 'round-div', name)
      end
    end

    def expect_button_within_course_fieldset(page_or_rendered, names)
      expect(page_or_rendered).to have_selector('fieldset', count: 1, text: Fieldset::Course::COURSE_BUTTONS)
      expect_button_count(page_or_rendered, 'course-div', names.size)
      names.each do |name|
        expect_button_to(page_or_rendered, 'course-div', name)
      end
    end

    def expect_have_field_text(page, field_name, field_id, value, disabled, pre_selector = '')
      expect(page).to have_field(field_name, disabled: disabled, count: 1)
      expect(page).to have_selector("#{pre_selector}input[type=text][id=#{field_id}][value='#{value}']")
    end

    def expect_have_field_num(page, field_name, field_id, value, disabled)
      expect(page).to have_field(field_name, disabled: disabled, count: 1)
      expect(page).to have_selector("input[type=number][id=#{field_id}][value=#{value}]")
    end

    private

    def expect_button_count(page_or_rendered, div_id, num)
      expect(page_or_rendered).to have_selector(button_count_selector(div_id), count: num)
    end

    def button_count_selector(id)
      "div[id=#{id}][class=fieldset-button-div] form[class=button_to] input[type=submit]"
    end

    def expect_button_to(page_or_rendered, div_id, name)
      # rubocop:disable Layout/LineLength
      expect(page_or_rendered).to have_selector("div[id=#{div_id}][class=fieldset-button-div] form[class=button_to] input[type=submit][value='#{name}']", count: 1)
      # rubocop:enable Layout/LineLength
    end
  end
end
