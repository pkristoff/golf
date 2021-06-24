# frozen_string_literal: true

require 'common/button_to_common'

module RoundsCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include ButtonToCommon

    def expect_rounds_course_index(rendered_or_page, courses)
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

    def expect_rounds_index(rendered_or_page, course, tee, rounds, show_tees)
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

    def expect_round_form_fields(rendered_or_page, values, update_create)
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      new_edit = update_create == Button::Round::UPDATE ? Label::Round::EDIT : Label::Round::NEW

      expect(rendered_or_page).to have_selector('h1', count: 1, text: new_edit)
      expect(rendered_or_page).to have_selector('h2', count: 1, text: "Course: #{values[:course_name]}")
      expect(rendered_or_page).to have_selector('h2', count: 1, text: "Tee: #{values[:tee_color]}")
      expect(rendered_or_page).to have_selector("input[type=date][id=round_date][value='#{values[:date]}']", count: 1)
      expect(rendered_or_page).to have_button(update_create, count: 1)
    end

    def expect_show_round_form_fields(rendered_or_page, values)
      disabled = values[:disabled].nil? ? false : values[:disabled]
      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      expect(rendered_or_page).to have_selector('h1', count: 1, text: Label::Round::SHOW)
      expect(rendered_or_page).to have_selector('h2', count: 1, text: "Course: #{values[:course_name]}")
      expect(rendered_or_page).to have_selector('h2', count: 1, text: values[:color])
      # rubocop:disable Layout/LineLength
      expect(rendered_or_page).to have_selector("input[type=date][id=round_date][value='#{values[:date]}']", count: 1) unless disabled
      expect(rendered_or_page).to have_selector("input[type=date][id=round_date][disabled=disabled][value='#{values[:date]}']", count: 1) if disabled
      # rubocop:enable Layout/LineLength
    end

    private

    def expect_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page, [Button::Course::NEW])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
    end

    def expect_tees_round_other_buttons(rendered_or_page)
      # rubocop:disable Layout/LineLength
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page, [Button::Course::NEW, Button::Course::EDIT, Button::Tee::NEW])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [])
      # rubocop:enable Layout/LineLength
    end

    def expect_round_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(
        rendered_or_page,
        [Button::Course::NEW, Button::Course::EDIT, Button::Tee::NEW, Button::Tee::EDIT]
      )
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page,
                                                         [
                                                           Button::Round::NEW
                                                         ])
    end
  end
end
