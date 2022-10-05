# frozen_string_literal: true

require 'common/button_to_common'
require 'common/method_common'

# RoundCommon
#
module RoundsCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include ButtonToCommon
    include MethodCommon

    # expect list of courses to get rounds
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:courses</tt> list of courses
    #
    def expect_index_rounds_course(rendered_or_page, courses)
      AsideCommon.expect_aside(rendered_or_page, false) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_menu(rendered_or_page) unless rendered_or_page.is_a? String

      expect(rendered_or_page).to have_selector('h1', text: I18n.t('button.round.choose_round_course'))
      courses.each do |course|
        expect(rendered_or_page).to have_link(course.name)
      end
      expect_other_buttons(rendered_or_page)
    end

    # expect rounds and tees
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:course</tt> chosen Course
    # * <tt>:tees</tt> tees for course
    #
    def expect_rounds_tees(rendered_or_page, course, tees)
      AsideCommon.expect_aside(rendered_or_page, true) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_menu(rendered_or_page) unless rendered_or_page.is_a? String

      expect(rendered_or_page).to have_selector('h1', text: 'Rounds')
      expect(rendered_or_page).to have_selector('h1', text: "Choose Tee for course #{course.name}")

      tees.each do |tee|
        expect(rendered_or_page).to have_link(tee.color)
        expect(rendered_or_page).to have_link("link-tee-#{tee.id}", text: tee.color, count: 1)
        expect(rendered_or_page).to have_link("analyze-tee-#{tee.id}", text: I18n.t('button.tee.analyze'), count: 1)
      end

      expect_tees_round_other_buttons(rendered_or_page)
    end

    # expect list of rounds choose one
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:course</tt> score being edited
    # * <tt>:tee</tt> tee of course
    # * <tt>:rounds</tt> list of rounds for course & tee
    # * <tt>:show_tees</tt> show tee button in the aside
    #
    def expect_index_rounds(rendered_or_page, course, tee, rounds, show_tees)
      AsideCommon.expect_aside(rendered_or_page, show_tees) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_menu(rendered_or_page) unless rendered_or_page.is_a? String
      expect(rendered_or_page).to have_selector('h1', text: "Rounds for #{course.name} and tee #{tee.color}")
      if rounds.empty?
        expect(rendered_or_page).to have_selector('p', text: I18n.t('info.round.no_rounds_to_analyze'))
        expect(rendered_or_page).to have_selector('p', text: I18n.t('info.round.no_rounds'))
      else
        rounds.each do |round|
          expect(rendered_or_page).to have_link(round.date.to_s)
        end
        expect(rendered_or_page).to have_link('show analysis of tee')
      end
      expect_round_other_buttons(rendered_or_page)
    end

    # expect edit round
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:round</tt> round being edited
    # * <tt>:values</tt> Hash of symbol value pairs
    #
    def expect_edit_round(rendered_or_page, round, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_menu(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, I18n.t('heading.round.edit'))

      expect_edit_fieldset_round(rendered_or_page,
                                 round,
                                 false,
                                 values)

      expect_edit_other_buttons(rendered_or_page)
    end

    # expect new round
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:tee</tt> score being edited
    # * <tt>:values</tt> Hash of symbol value pairs
    #
    def expect_new_round(rendered_or_page, tee, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_menu(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, I18n.t('heading.round.new'))

      expect_new_fieldset_round(rendered_or_page,
                                tee,
                                false,
                                values)

      expect(rendered_or_page).to have_button(I18n.t('button.round.create'), count: 1)

      expect_new_other_buttons(rendered_or_page)
    end

    # expect show round
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:round</tt> round bbeing shown
    # * <tt>:values</tt> Hash of symbol value pairs
    #
    def expect_show_round(rendered_or_page, round, values = {})
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_menu(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, I18n.t('heading.round.show'))

      expect_show_fieldset_round(rendered_or_page,
                                 round,
                                 true,
                                 values)

      expect(rendered_or_page).not_to have_button(I18n.t('button.round.create'), count: 1)
      expect(rendered_or_page).not_to have_button(I18n.t('button.round.update'), count: 1)

      expect_show_other_buttons(rendered_or_page)
    end

    private

    def expect_show_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            I18n.t('button.course.edit'),
                                            I18n.t('button.course.new'),
                                            I18n.t('button.tee.new'),
                                            I18n.t('button.tee.edit')
                                          ],
                                          [
                                            I18n.t('button.round.edit_round'),
                                            I18n.t('button.round.destroy_round'),
                                            I18n.t('button.round.new_round')
                                          ])
    end

    def expect_edit_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            I18n.t('button.course.edit'),
                                            I18n.t('button.course.new'),
                                            I18n.t('button.tee.new'),
                                            I18n.t('button.tee.edit')
                                          ],
                                          [
                                            I18n.t('button.round.edit_round'),
                                            I18n.t('button.round.new_round')
                                          ])
    end

    def expect_new_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            I18n.t('button.course.edit'),
                                            I18n.t('button.course.new'),
                                            I18n.t('button.tee.new'),
                                            I18n.t('button.tee.edit')
                                          ],
                                          [I18n.t('button.round.new_round')])
    end

    def expect_new_fieldset_round(rendered_or_page, tee, disabled, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: I18n.t('fieldset.edit.text'))
      fieldset_subheading = Selector::Edit::SUBHEADING
      expect_new_subheading(rendered_or_page, values, fieldset_subheading)
      form_txt = " form[action='/courses/#{tee.course.id}/tees/#{tee.id}/rounds'] "
      fieldset_form_txt = Selector::Edit::EDIT + form_txt
      expect_editable_field_values_round(rendered_or_page, disabled, values, fieldset_form_txt)

      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, false, I18n.t('button.round.create'))
    end

    def expect_edit_fieldset_round(rendered_or_page, round, disabled, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: I18n.t('fieldset.edit.text'))
      fieldset_subheading = Selector::Edit::SUBHEADING
      expect_edit_subheading(rendered_or_page, values, fieldset_subheading)
      form_txt = " form[action='/courses/#{round.tee.course.id}/tees/#{round.tee.id}/rounds/#{round.id}'] "
      fieldset_form_txt = Selector::Edit::EDIT + form_txt
      expect_editable_field_values_round(rendered_or_page, disabled, values, fieldset_form_txt)

      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, false, I18n.t('button.round.update'))
    end

    def expect_show_fieldset_round(rendered_or_page, round, disabled, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: I18n.t('fieldset.edit.text'))
      expect_show_subheading(rendered_or_page, values, Selector::Edit::SUBHEADING)
      form_txt = " form[action='/courses/#{round.tee.course.id}/tees/#{round.tee.id}/rounds/#{round.id}'] "
      fieldset_form_txt = Selector::Edit::EDIT + form_txt
      expect_editable_field_values_round(rendered_or_page, disabled, values, fieldset_form_txt)

      ButtonToCommon.expect_submit_button(rendered_or_page, fieldset_form_txt, true, I18n.t('button.round.update'))
    end

    def expect_editable_field_values_round(rendered_or_page, disabled, values, fieldset_form_txt)
      date = values[:date]
      raise('date not set') if date.nil?

      MethodCommon.expect_have_field_date(rendered_or_page,
                                          I18n.t('activerecord.attributes.round.date'),
                                          'round_date',
                                          date,
                                          disabled,
                                          fieldset_form_txt)
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
                                            I18n.t('button.course.new')
                                          ],
                                          [])
    end

    def expect_tees_round_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            I18n.t('button.course.edit'),
                                            I18n.t('button.course.new'),
                                            I18n.t('button.tee.new')
                                          ],
                                          [])
    end

    def expect_round_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            I18n.t('button.course.edit'),
                                            I18n.t('button.course.new'),
                                            I18n.t('button.tee.new'),
                                            I18n.t('button.tee.edit')
                                          ],
                                          [I18n.t('button.round.new_round')])
    end
  end
end
