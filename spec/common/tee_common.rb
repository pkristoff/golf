# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'

module TeeCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include AsideCommon
    include DatabaseCommon
    include ButtonToCommon

    def expect_tee_form_fields(rendered_or_page, tees, values, update_create)
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)
      expect_messages(values[:expect_messages], rendered_or_page) unless values[:expect_messages].nil?

      new_edit = update_create == 'Update' ? Heading::Tee::EDIT_TEE : Heading::Tee::NEW_TEE

      expect(rendered_or_page).to have_selector('h1', count: 1, text: new_edit)
      expect(rendered_or_page).to have_selector('h2', count: 1, text: "Course: #{values[:course_name]}")
      expect(rendered_or_page).to have_selector('h2', count: 1, text: "Tee: #{values[:number]}")

      expect_tees(rendered_or_page, tees)

      ButtonToCommon.expect_have_field_text(rendered_or_page, Label::Tee::COLOR, 'tee_color', values[:color], false)
      ButtonToCommon.expect_have_field_num(rendered_or_page, Label::Tee::SLOPE, 'tee_slope', "'#{values[:slope]}'", false)
      ButtonToCommon.expect_have_field_num(rendered_or_page, Label::Tee::RATING, 'tee_rating', "'#{values[:rating]}'", false)

      expect(rendered_or_page).to have_button("#{update_create} Tee")
      expect(rendered_or_page).to have_button(Button::Course::EDIT)
      expect(rendered_or_page).to have_button(Button::Tee::NEW) if update_create == 'Update'
    end

    def expect_tees_page(rendered_or_page, course, tees, show_tees)
      include AsideCommon unless rendered_or_page.is_a?(String)
      include DatabaseCommon unless rendered_or_page.is_a?(String)
      AsideCommon.expect_aside(rendered_or_page, show_tees) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)

      expect(rendered_or_page).to have_selector('h1', count: 1, text: "Pick Tee for course: #{course.name}")

      expect_tees(rendered_or_page, tees)
    end

    def expect_tees(rendered_or_page, tees)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Tees::TEES)
      fieldset_locator = 'div[id=tees-div][class=fieldset-field-div]'
      if tees.empty?
        expect(rendered_or_page).to have_selector("#{fieldset_locator} p", count: 1, text: 'No tees')
      else
        # Check table headers
        expect(rendered_or_page).to have_selector("#{fieldset_locator} table[id=tees]", count: 1)
        expect(rendered_or_page).to have_selector("#{fieldset_locator} th[id=tees-color]", count: 1, text: 'Color')
        expect(rendered_or_page).to have_selector("#{fieldset_locator} th[id=tees-slope]", count: 1, text: 'Slope')
        expect(rendered_or_page).to have_selector("#{fieldset_locator} th[id=tees-rating]", count: 1, text: 'Rating')

        tees.each do |tee|
          expect(rendered_or_page).to have_selector("tr[id=tee-#{tee.id}]", count: 1)
          expect(rendered_or_page).to have_selector("td[id=tee-color-#{tee.id}]", count: 1, text: tee.color)
          expect(rendered_or_page).to have_selector("td[id=tee-slope-#{tee.id}]", count: 1, text: tee.slope)
          expect(rendered_or_page).to have_selector("td[id=tee-rating-#{tee.id}]", count: 1, text: tee.rating)

          expect(rendered_or_page).to have_selector("td[id=hole-number-heading-#{tee.id}]", count: 1, text: 'Number:')
          expect(rendered_or_page).to have_selector("td[id=hole-yardage-heading-#{tee.id}]", count: 1, text: 'Yardage:')
          expect(rendered_or_page).to have_selector("td[id=hole-par-heading-#{tee.id}]", count: 1, text: 'Par:')
          expect(rendered_or_page).to have_selector("td[id=hole-hdcp-heading-#{tee.id}]", count: 1, text: 'HDCP:')
          tee.sorted_holes.each do |hole|
            # rubocop:disable Layout/LineLength
            expect(rendered_or_page).to have_selector("tr[id=hole-number-#{tee.id}] td[id=hole-number-#{hole.id}]", count: 1, text: hole.number)
            expect(rendered_or_page).to have_selector("tr[id=hole-yardage-#{tee.id}] td[id=hole-yardage-#{hole.id}]", count: 1, text: hole.yardage)
            expect(rendered_or_page).to have_selector("tr[id=hole-par-#{tee.id}] td[id=hole-par-#{hole.id}]", count: 1, text: hole.par)
            expect(rendered_or_page).to have_selector("tr[id=hole-hdcp-#{tee.id}] td[id=hole-hdcp-#{hole.id}]", count: 1, text: hole.hdcp)
            # rubocop:enable Layout/LineLength
          end
        end

      end
    end
  end
end
