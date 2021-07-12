# frozen_string_literal: true

module MethodCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders

    def expect_have_field_text(rendered_or_page, field_name, field_id, value, disabled, pre_selector = '')
      expect(rendered_or_page).to have_field(field_name, disabled: disabled, count: 1)
      expect(rendered_or_page).to have_selector("#{pre_selector}input[type=text][id=#{field_id}][value='#{value}']")
    end

    def expect_have_field_date(rendered_or_page, field_name, field_id, value, disabled, pre_selector = '')
      expect(rendered_or_page).to have_field(field_name, disabled: disabled, count: 1)
      expect(rendered_or_page).to have_selector("#{pre_selector}input[type=date][id=#{field_id}][value='#{value}']")
    end

    def expect_have_field_num(rendered_or_page, field_name, field_id, value, disabled, pre_selector = '')
      expect(rendered_or_page).to have_field(field_name, disabled: disabled, count: 1)
      expect(rendered_or_page).to have_selector("#{pre_selector}input[type=number][id=#{field_id}][value=#{value}]")
    end

    def expect_heading(rendered_or_page, heading)
      expect(rendered_or_page).to have_selector('h1', count: 1, text: heading)
    end

    def expect_subheading(rendered_or_page, heading, fieldset = '')
      expect(rendered_or_page).to have_selector("#{fieldset}h2", count: 1, text: heading)
    end
  end
end
