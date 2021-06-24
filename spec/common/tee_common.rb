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

    def expect_tee_form_fields(page_or_rendered, tees, values, update_create)
      AsideCommon.expect_aside(page_or_rendered, values[:show_tees]) unless page_or_rendered.is_a?(String)
      DatabaseCommon.expect_database(page_or_rendered) unless page_or_rendered.is_a?(String)
      expect_messages(values[:expect_messages], page_or_rendered) unless values[:expect_messages].nil?

      new_edit = update_create == 'Update' ? 'Edit' : 'New'

      expect(page_or_rendered).to have_selector('h1', count: 1, text: "#{new_edit} tee:")
      expect(page_or_rendered).to have_selector('h2', count: 1, text: 'Course: George')
      expect(page_or_rendered).to have_selector('h2', count: 1, text: "Tee: #{values[:number]}")

      expect_tees(page_or_rendered, tees)

      ButtonToCommon.expect_have_field_text(page_or_rendered, Label::Tee::COLOR, 'tee_color', values[:color], false)
      ButtonToCommon.expect_have_field_num(page_or_rendered, Label::Tee::SLOPE, 'tee_slope', "'#{values[:slope]}'", false)
      ButtonToCommon.expect_have_field_num(page_or_rendered, Label::Tee::RATING, 'tee_rating', "'#{values[:rating]}'", false)

      expect(page_or_rendered).to have_button("#{update_create} Tee")
      expect(page_or_rendered).to have_button(Button::Course::EDIT)
      expect(page_or_rendered).to have_button(Button::Tee::NEW) if update_create == 'Update'
    end

    def expect_tees_page(page_or_rendered, course, tees, show_tees)
      include AsideCommon unless page_or_rendered.is_a?(String)
      include DatabaseCommon unless page_or_rendered.is_a?(String)
      AsideCommon.expect_aside(page_or_rendered, show_tees) unless page_or_rendered.is_a?(String)
      DatabaseCommon.expect_database(page_or_rendered) unless page_or_rendered.is_a?(String)

      expect(page_or_rendered).to have_selector('h1', count: 1, text: "Pick Tee for course: #{course.name}")

      expect_tees(page_or_rendered, tees)
    end

    def expect_tees(page_or_rendered, tees)
      expect(page_or_rendered).to have_selector('fieldset', count: 1, text: Fieldset::Tees::TEES)
      fieldset_locator = 'div[id=tees-div][class=fieldset-field-div]'
      if tees.empty?
        expect(page_or_rendered).to have_selector("#{fieldset_locator} p", count: 1, text: 'No tees')
      else
        # Check table headers
        expect(page_or_rendered).to have_selector("#{fieldset_locator} table[id=tees]", count: 1)
        expect(page_or_rendered).to have_selector("#{fieldset_locator} th[id=tees-color]", count: 1, text: 'Color')
        expect(page_or_rendered).to have_selector("#{fieldset_locator} th[id=tees-slope]", count: 1, text: 'Slope')
        expect(page_or_rendered).to have_selector("#{fieldset_locator} th[id=tees-rating]", count: 1, text: 'Rating')

        tees.each do |tee|
          expect(page_or_rendered).to have_selector("tr[id=tee-#{tee.id}]", count: 1)
          expect(page_or_rendered).to have_selector("td[id=tee-color-#{tee.id}]", count: 1, text: tee.color)
          expect(page_or_rendered).to have_selector("td[id=tee-slope-#{tee.id}]", count: 1, text: tee.slope)
          expect(page_or_rendered).to have_selector("td[id=tee-rating-#{tee.id}]", count: 1, text: tee.rating)

          expect(page_or_rendered).to have_selector("td[id=hole-number-heading-#{tee.id}]", count: 1, text: 'Number:')
          expect(page_or_rendered).to have_selector("td[id=hole-yardage-heading-#{tee.id}]", count: 1, text: 'Yardage:')
          expect(page_or_rendered).to have_selector("td[id=hole-par-heading-#{tee.id}]", count: 1, text: 'Par:')
          expect(page_or_rendered).to have_selector("td[id=hole-hdcp-heading-#{tee.id}]", count: 1, text: 'HDCP:')
          tee.sorted_holes.each do |hole|
            # rubocop:disable Layout/LineLength
            expect(page_or_rendered).to have_selector("tr[id=hole-number-#{tee.id}] td[id=hole-number-#{hole.id}]", count: 1, text: hole.number)
            expect(page_or_rendered).to have_selector("tr[id=hole-yardage-#{tee.id}] td[id=hole-yardage-#{hole.id}]", count: 1, text: hole.yardage)
            expect(page_or_rendered).to have_selector("tr[id=hole-par-#{tee.id}] td[id=hole-par-#{hole.id}]", count: 1, text: hole.par)
            expect(page_or_rendered).to have_selector("tr[id=hole-hdcp-#{tee.id}] td[id=hole-hdcp-#{hole.id}]", count: 1, text: hole.hdcp)
            # rubocop:enable Layout/LineLength
          end
        end

      end
    end
  end
end
