# frozen_string_literal: true

require 'common/button_to_common'
require 'common/method_common'

module RoundsCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include ButtonToCommon
    include MethodCommon

    def expect_index_rounds_course(rendered_or_page, courses)
      AsideCommon.expect_aside(rendered_or_page, false) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect(rendered_or_page).to have_selector('h1', text: Button::Round::CHOOSE_COURSE)
      courses.each do |course|
        expect(rendered_or_page).to have_link(course.name)
      end
      expect_other_buttons(rendered_or_page)
    end

    def expect_rounds_tees(rendered_or_page, course, tees)
      AsideCommon.expect_aside(rendered_or_page, true) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect(rendered_or_page).to have_selector('h1', text: 'Rounds')
      expect(rendered_or_page).to have_selector('h1', text: "Choose Tee for course #{course.name}")

      tees.each do |tee|
        expect(rendered_or_page).to have_link(tee.color)
      end

      expect_tees_round_other_buttons(rendered_or_page)
    end

    def expect_index_rounds(rendered_or_page, course, tee, rounds, show_tees)
      AsideCommon.expect_aside(rendered_or_page, show_tees) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String
      expect(rendered_or_page).to have_selector('h1', text: "Rounds for #{course.name} and tee #{tee.color}")
      if rounds.empty?
        expect(rendered_or_page).to have_selector('p', text: Label::Round::NO_ROUNDS)
      else
        rounds.each do |round|
          expect(rendered_or_page).to have_link(round.date.to_s)
        end
      end
      expect_round_other_buttons(rendered_or_page)
    end

    def expect_edit_round(rendered_or_page, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Round::EDIT)

      expect_edit_fieldset_round(rendered_or_page, false, values)

      expect(rendered_or_page).to have_button(Button::Round::UPDATE, count: 1)

      expect_edit_other_buttons(rendered_or_page)
    end

    def expect_new_round(rendered_or_page, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Round::NEW)

      expect_new_fieldset_round(rendered_or_page, false, values)

      expect(rendered_or_page).to have_button(Button::Round::CREATE, count: 1)

      expect_new_other_buttons(rendered_or_page)
    end

    def expect_show_round(rendered_or_page, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Round::SHOW)

      expect_show_fieldset_round(rendered_or_page, true, values)

      expect(rendered_or_page).not_to have_button(Button::Round::CREATE, count: 1)
      expect(rendered_or_page).not_to have_button(Button::Round::UPDATE, count: 1)

      expect_show_other_buttons(rendered_or_page)
    end

    private

    def expect_show_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Course::NEW,
                                            Button::Tee::NEW,
                                            Button::Tee::EDIT
                                          ],
                                          [
                                            Button::Round::EDIT,
                                            Button::Round::DESTROY,
                                            Button::Round::NEW
                                          ])
    end

    def expect_edit_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Course::NEW,
                                            Button::Tee::NEW,
                                            Button::Tee::EDIT
                                          ],
                                          [
                                            Button::Round::EDIT,
                                            Button::Round::NEW
                                          ])
    end

    def expect_new_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Course::NEW,
                                            Button::Tee::NEW,
                                            Button::Tee::EDIT
                                          ],
                                          [Button::Round::NEW])
    end

    def expect_new_fieldset_round(rendered_or_page, disabled, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Edit::HEADING)
      fieldset_subheading = Fieldset::Edit::SUBHEADING
      expect_new_subheading(rendered_or_page, values, fieldset_subheading)
      fieldset_edit = Fieldset::Edit::EDIT
      expect_editable_field_values(rendered_or_page, disabled, values, fieldset_edit)
    end

    def expect_edit_fieldset_round(rendered_or_page, disabled, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Edit::HEADING)
      fieldset_subheading = Fieldset::Edit::SUBHEADING
      expect_edit_subheading(rendered_or_page, values, fieldset_subheading)
      fieldset_edit = Fieldset::Edit::EDIT
      expect_editable_field_values(rendered_or_page, disabled, values, fieldset_edit)
    end

    def expect_show_fieldset_round(rendered_or_page, disabled, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Edit::HEADING)
      expect_show_subheading(rendered_or_page, values, Fieldset::Edit::SUBHEADING)
      expect_editable_field_values(rendered_or_page, disabled, values, Fieldset::Edit::EDIT)
    end

    def expect_editable_field_values(rendered_or_page, disabled, values, fieldset_edit)
      date = values[:date]
      raise('date not set') if date.nil?

      MethodCommon.expect_have_field_date(rendered_or_page,
                                          Label::Round::DATE,
                                          'round_date',
                                          date,
                                          disabled,
                                          fieldset_edit)
    end

    def expect_show_subheading(rendered_or_page, values, fieldset_subheading)
      MethodCommon.expect_subheading(rendered_or_page, "Course: #{values[:course_name]}", fieldset_subheading)
      MethodCommon.expect_subheading(rendered_or_page, "Tee: #{values[:tee_color]}", fieldset_subheading)
    end

    def expect_new_subheading(rendered_or_page, values, fieldset_subheading)
      MethodCommon.expect_subheading(rendered_or_page, "Course: #{values[:course_name]}", fieldset_subheading)
      MethodCommon.expect_subheading(rendered_or_page, "Tee: #{values[:tee_color]}", fieldset_subheading)
    end

    def expect_edit_subheading(rendered_or_page, values, fieldset_subheading)
      MethodCommon.expect_subheading(rendered_or_page, "Course: #{values[:course_name]}", fieldset_subheading)
      MethodCommon.expect_subheading(rendered_or_page, "Tee: #{values[:tee_color]}", fieldset_subheading)
    end

    def expect_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::NEW
                                          ],
                                          [])
    end

    def expect_tees_round_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Course::NEW,
                                            Button::Tee::NEW
                                          ],
                                          [])
    end

    def expect_round_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Course::NEW,
                                            Button::Tee::NEW,
                                            Button::Tee::EDIT
                                          ],
                                          [Button::Round::NEW])
    end
  end
end
