# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'
require 'common/method_common'

module TeeCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include AsideCommon
    include DatabaseCommon
    include ButtonToCommon
    include MethodCommon

    def expect_new_fields_with_values(rendered_or_page, tees, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)

      expect_messages(values[:expect_messages], rendered_or_page) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Tee::NEW_TEE)

      expect_tees(rendered_or_page, tees)

      expect_new_fieldset(rendered_or_page, values)

      expect(rendered_or_page).to have_button('Create Tee', count: 1)

      expect_new_other_buttons(rendered_or_page)
    end

    def expect_edit_fields_with_values(rendered_or_page, tees, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)

      expect_messages(values[:expect_messages], rendered_or_page) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Tee::EDIT_TEE)

      expect_tees(rendered_or_page, tees)

      expect_edit_fieldset(rendered_or_page, values)

      expect(rendered_or_page).to have_button('Update Tee', count: 1)

      expect_edit_other_buttons(rendered_or_page)
    end

    def expect_index_tees(rendered_or_page, course, tees, show_tees)
      include AsideCommon unless rendered_or_page.is_a?(String)
      include DatabaseCommon unless rendered_or_page.is_a?(String)
      AsideCommon.expect_aside(rendered_or_page, show_tees) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)

      MethodCommon.expect_heading(rendered_or_page, "#{Heading::Tee::PICK} #{course.name}")

      expect_tees(rendered_or_page, tees)

      expect_index_other_buttons(rendered_or_page)
    end

    def expect_tees(rendered_or_page, tees)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Tee::TEES)
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

    private

    def expect_edit_fieldset(rendered_or_page, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Tee::EDIT)
      fieldset_subheading = 'div[id=subheading-div][class=fieldset-field-div] '
      MethodCommon.expect_subheading(rendered_or_page, "Course: #{values[:course_name]}", fieldset_subheading)
      MethodCommon.expect_subheading(rendered_or_page, "Tee: #{values[:number]}", fieldset_subheading)
      fieldset_edit = 'div[id=edit-div][class=fieldset-field-div] '
      expect_editable_field_values(rendered_or_page, values, fieldset_edit)
    end

    def expect_new_fieldset(rendered_or_page, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Tee::EDIT)
      fieldset_subheading = 'div[id=subheading-div][class=fieldset-field-div] '
      MethodCommon.expect_subheading(rendered_or_page, "Course: #{values[:course_name]}", fieldset_subheading)
      fieldset_edit = 'div[id=edit-div][class=fieldset-field-div] '
      expect_editable_field_values(rendered_or_page, values, fieldset_edit)
    end

    def expect_new_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [Button::Course::EDIT])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_edit_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [Button::Course::EDIT,
                                                           Button::Tee::NEW])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_index_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [Button::Course::EDIT,
                                                           Button::Tee::NEW])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_editable_field_values(rendered_or_page, values, fieldset_edit)
      MethodCommon.expect_have_field_text(rendered_or_page, Label::Tee::COLOR, 'tee_color', values[:color], false, fieldset_edit)
      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Tee::SLOPE,
                                         'tee_slope',
                                         "'#{values[:slope]}'",
                                         false,
                                         fieldset_edit)
      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Tee::RATING,
                                         'tee_rating',
                                         "'#{values[:rating]}'",
                                         false,
                                         fieldset_edit)
    end

    def expect_subheadings(rendered_or_page, new_edit, values)
      expect(rendered_or_page).to have_selector('h2', count: 1, text: "Course: #{values[:course_name]}")
      # rubocop:disable Layout/LineLength
      expect(rendered_or_page).to have_selector('h2', count: 1, text: "Tee: #{values[:number]}") unless new_edit == Heading::Tee::NEW_TEE
      # rubocop:enable Layout/LineLength
    end

    def expect_course_values(page, values, disabled)
      MethodCommon.expect_have_field_text(page, Label::Tee::COLOR, 'tee_color', values[:color], disabled)
      MethodCommon.expect_have_field_num(page,
                                         Label::Tee::SLOPE,
                                         'tee_slope',
                                         values[:slope],
                                         disabled)
      MethodCommon.expect_have_field_num(page,
                                         Label::Tee::RATING,
                                         'tee_rating',
                                         values[:rating],
                                         disabled)
    end
  end
end
