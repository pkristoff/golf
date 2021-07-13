# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'
require 'common/tee_common'
require 'common/method_common'

module CourseCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include AsideCommon
    include DatabaseCommon
    include ButtonToCommon
    include TeeCommon
    include MethodCommon

    def expect_edit_fields_with_values(page, tees, values = {})
      AsideCommon.expect_aside(page, values[:show_tees])
      DatabaseCommon.expect_database(page)

      MethodCommon.expect_heading(page, Heading::Course::EDIT_COURSE)

      TeeCommon.expect_tees(page, tees)

      expect_course_values(page, values, false)

      expect_address_fields(page, values, false)

      expect(page).to have_button(Button::Course::UPDATE, count: 1)

      expect_edit_other_buttons(page)
    end

    def expect_new_fields_with_values(page, values = {})
      AsideCommon.expect_aside(page, values[:show_tees])
      DatabaseCommon.expect_database(page)

      MethodCommon.expect_heading(page, Heading::Course::NEW_COURSE)

      expect(page).to have_button(Button::Course::SUBMIT, count: 1)
      TeeCommon.expect_tees(page, [])
      expect_course_values(page, values, false)
      expect_address_fields(page, values, false)
      expect(page).to have_button(Button::Course::CREATE, count: 1)

      expect_new_other_buttons(page)
    end

    def expect_course_index(rendered_or_page, courses)
      MethodCommon.expect_heading(rendered_or_page, Heading::Course::COURSES)
      expect_number_of_courses(rendered_or_page, courses)
      if courses.empty?
        expect(rendered_or_page).to have_selector('h2', text: Heading::Course::NO_COURSES)
      else
        courses.each do |course|
          expect(rendered_or_page).to have_selector("a[id='edit_link_#{course.id}']", text: course.name)
        end
      end
      expect_index_other_buttons(rendered_or_page)
    end

    def expect_validation_errors(page, invalid_field_names, valid_field_names)
      invalid_field_names.each do |field_name|
        expect(page).to have_selector("div[class=field_with_errors] input[id=#{field_name}]")
      end
      valid_field_names.each do |field_name|
        expect(page).not_to have_selector("div[class=field_with_errors] input[id=#{field_name}]")
      end
    end

    def expect_show_fields_with_values(page, tees, values = {})
      AsideCommon.expect_aside(page, values[:show_tees])
      DatabaseCommon.expect_database(page)

      MethodCommon.expect_heading(page, Heading::Course::SHOW_COURSE)

      TeeCommon.expect_tees(page, tees)

      expect_course_values(page, values, true)

      expect_address_fields(page, values, true)

      expect(page).to have_button(Button::Course::SUBMIT, count: 0)
      expect(page).to have_button(Button::Course::UPDATE, count: 0)

      expect_show_other_buttons(page)
    end

    def expect_form_fields(rendered, disabled, tees, button_name, values)
      TeeCommon.expect_tees(rendered, tees)
      expect_course_values(rendered, values, disabled)

      expect_address_fields(rendered, values, disabled)

      expect(rendered).to have_button(button_name) unless disabled
      expect(rendered).not_to have_button(button_name) if disabled

      expect_new_other_buttons(rendered) if button_name == Button::Course::CREATE && !disabled
      expect_edit_other_buttons(rendered) if button_name == Button::Course::UPDATE && !disabled
      expect_show_other_buttons(rendered) if disabled
    end

    private

    def expect_number_of_courses(rendered_or_page, courses)
      expect(rendered_or_page).to have_selector("li[id='li-id']", count: courses.size)
    end

    def expect_course_values(page, values, disabled)
      MethodCommon.expect_have_field_text(page, Label::Course::NAME, 'course_name', values[:course_name], disabled)
      MethodCommon.expect_have_field_num(page,
                                         Label::Course::NUMBER_OF_HOLES,
                                         'course_number_of_holes',
                                         values[:number_of_holes],
                                         disabled)
    end

    def expect_edit_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [Button::Course::NEW,
                                                           Button::Tee::NEW])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_index_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [Button::Course::NEW])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_new_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [Button::Course::NEW])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_show_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [
                                                            Button::Course::EDIT,
                                                            Button::Course::DESTROY,
                                                            Button::Course::NEW,
                                                            Button::Tee::NEW
                                                          ])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_address_fields(rendered_or_page, values, disabled)
      fieldset_locator = 'div[id=address-div][class=fieldset-field-div] '
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Course::STREET1,
                                          'course_address_attributes_street_1',
                                          values[:street_1],
                                          disabled,
                                          fieldset_locator)
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Course::STREET2,
                                          'course_address_attributes_street_2',
                                          values[:street_2],
                                          disabled,
                                          fieldset_locator)
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Course::CITY,
                                          'course_address_attributes_city',
                                          values[:city],
                                          disabled,
                                          fieldset_locator)
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Course::STATE,
                                          'course_address_attributes_state',
                                          values[:state],
                                          disabled,
                                          fieldset_locator)
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Course::ZIP,
                                          'course_address_attributes_zip_code',
                                          values[:zip_code],
                                          disabled,
                                          fieldset_locator)
    end

    def expect_address_field_set(rendered_or_page, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Course::ADDRESS)
      expect_within_edit_fieldset(rendered_or_page, values)
    end
  end
end
