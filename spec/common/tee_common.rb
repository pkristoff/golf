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

    # expect new tee
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:course</tt> course for new tee
    # * <tt>:tees</tt> list of tees o course
    # * <tt>:values</tt> Hash of symbol value pairs
    #
    def expect_new_tee(rendered_or_page, course, tees, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)

      expect_messages(values[:expect_messages], rendered_or_page) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Tee::NEW_TEE)

      expect_tees(rendered_or_page, tees)

      expect_new_fieldset_tee(rendered_or_page, course, values)

      expect_new_other_buttons(rendered_or_page)
    end

    # expect edit tee
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:tee</tt> expecting to edit
    # * <tt>:tees</tt> list of tees o course
    # * <tt>:values</tt> Hash of symbol value pairs
    #
    def expect_edit_tee(rendered_or_page, tee, tees, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)

      expect_messages(values[:expect_messages], rendered_or_page) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Tee::EDIT_TEE)

      expect_tees(rendered_or_page, tees)

      expect_edit_fieldset_tee(rendered_or_page, tee, values)

      expect_edit_other_buttons(rendered_or_page)
    end

    # expect a list of tees
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:course</tt> course
    # * <tt>:tees</tt> list of tees o course
    # * <tt>:show_tees</tt> show tees for course if true
    #
    def expect_index_tees(rendered_or_page, course, tees, show_tees)
      include AsideCommon unless rendered_or_page.is_a?(String)
      include DatabaseCommon unless rendered_or_page.is_a?(String)
      AsideCommon.expect_aside(rendered_or_page, show_tees) unless rendered_or_page.is_a?(String)
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a?(String)

      MethodCommon.expect_heading(rendered_or_page, "#{Heading::Tee::PICK} #{course.name}")

      expect_tees(rendered_or_page, tees)

      expect_index_other_buttons(rendered_or_page)
    end

    # Are tees shown
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:tees</tt> list of tees
    #
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

    def expect_edit_fieldset_tee(rendered_or_page, tee, values)
      form_txt = "form[action='/courses/#{tee.course.id}/tees/#{tee.id}']"
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Edit::HEADING)
      expect_edit_subheadings(rendered_or_page, values, Fieldset::Edit::SUBHEADING)
      fieldset_form_txt = Fieldset::Edit::EDIT + form_txt
      expect(rendered_or_page).to have_selector(form_txt)

      expect_editable_field_values_tee(rendered_or_page, values, "#{fieldset_form_txt} ")

      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, false, 'Update Tee')
    end

    def expect_new_fieldset_tee(rendered_or_page, course, values)
      form_txt = "form[action='/courses/#{course.id}/tees']"
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Edit::HEADING)
      expect_new_subheadings(rendered_or_page, values, Fieldset::Edit::SUBHEADING)
      fieldset_form_txt = Fieldset::Edit::EDIT + form_txt
      expect(rendered_or_page).to have_selector(fieldset_form_txt)
      expect_editable_field_values_tee(rendered_or_page, values, "#{fieldset_form_txt} ")

      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, false, 'Create Tee')
    end

    def expect_new_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT
                                          ],
                                          [])
    end

    def expect_edit_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Tee::NEW
                                          ],
                                          [])
    end

    def expect_index_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Tee::NEW
                                          ],
                                          [])
    end

    def expect_editable_field_values_tee(rendered_or_page, values, fieldset_form_txt)
      tee_color = values[:tee_color]
      raise('tee_color not set') if tee_color.nil?

      MethodCommon.expect_have_field_text(rendered_or_page, Label::Tee::COLOR, 'tee_color', tee_color, false, fieldset_form_txt)
      tee_slope = values[:tee_slope]
      raise('tee_slope not set') if tee_slope.nil?

      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Tee::SLOPE,
                                         'tee_slope',
                                         "'#{tee_slope}'",
                                         false,
                                         fieldset_form_txt)
      tee_rating = values[:tee_rating]
      raise('tee_rating not set') if tee_rating.nil?

      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Tee::RATING,
                                         'tee_rating',
                                         "'#{tee_rating}'",
                                         false,
                                         fieldset_form_txt)
    end

    def expect_edit_subheadings(rendered_or_page, values, fieldset_subheading)
      MethodCommon.expect_subheading_course_name(rendered_or_page, values[:course_name], fieldset_subheading)
      MethodCommon.expect_subheading_tee_color(rendered_or_page, values[:tee_color], fieldset_subheading)
    end

    def expect_new_subheadings(rendered_or_page, values, fieldset_subheading)
      MethodCommon.expect_subheading_course_name(rendered_or_page, values[:course_name], fieldset_subheading)
    end
  end
end
