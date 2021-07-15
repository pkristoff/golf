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

    def expect_subheading_course_name(rendered_or_page, course_name, fieldset = '')
      raise('course_name not set') if course_name.nil?

      expect_subheading(rendered_or_page, "Course: #{course_name}", fieldset)
    end

    def expect_subheading_tee_color(rendered_or_page, tee_color, fieldset = '')
      raise('tee_color not set') if tee_color.nil?

      expect_subheading(rendered_or_page, "Tee: #{tee_color}", fieldset)
    end

    def expect_subheading_hole_number(rendered_or_page, hole_number, fieldset_subheading = '')
      raise('hole_number not set') if hole_number.nil?

      expect_subheading(rendered_or_page, "Hole: #{hole_number}", fieldset_subheading)
    end

    def expect_subheading_round_date(rendered_or_page, round_date, fieldset_subheading)
      raise('round_date not set') if round_date.nil?

      expect_subheading(rendered_or_page, "Date: #{round_date}", fieldset_subheading)
    end
  end
end
