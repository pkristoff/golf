# frozen_string_literal: true

module RoundsCommon
  def expect_rounds_index(courses)
    expect(rendered).to have_selector('h1', text: Button::Round::CHOOSE_COURSE)
    courses.each do |course|
      expect(rendered).to have_link(course.name)
    end
  end

  def expect_rounds_tees(course, tees)
    expect(rendered).to have_selector('h1', text: 'Rounds')
    expect(rendered).to have_selector('h1', text: "Choose Tee for course #{course.name}")

    tees.each do |tee|
      expect(rendered).to have_link(tee.color)
    end

    expect(rendered).to have_button(Button::Round::COURSES, count: 0)
    expect(rendered).to have_selector('input[type=submit]', count: 0)
  end

  def expect_rounds(course, tee, rounds)
    expect(rendered).to have_selector('h1', text: "Rounds for #{course.name} and tee #{tee.color}")
    if rounds.empty?
      expect(rendered).to have_selector('p', text: Label::Round::NO_ROUNDS)
    else
      rounds.each do |round|
        expect(rendered).to have_link(round.date.to_s)
      end
    end
    expect(rendered).to have_button(Button::Round::TEES, count: 1)
    expect(rendered).to have_button(Button::Round::COURSES, count: 0)
    expect(rendered).to have_selector('input[type=submit]', count: 3)
  end

  def expect_round_form_fields(page_or_rendered, _tee, values, update_create)
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    new_edit = update_create == 'Update' ? 'Edit' : 'New'

    expect(page_or_rendered).to have_selector('h1', count: 1, text: "#{new_edit} round")
    expect(page_or_rendered).to have_selector('h2', count: 1, text: "Course: #{values[:course_name]}")
    expect(page_or_rendered).to have_selector('h2', count: 1, text: 'Tee: Black')
  end
end
