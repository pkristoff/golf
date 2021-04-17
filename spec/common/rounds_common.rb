# frozen_string_literal: true

module RoundsCommon
  def expect_rounds_index(page_or_rendered, courses, show_course_tees, show_round_tees)
    expect_aside(page, show_course_tees, show_round_tees) unless page_or_rendered.is_a? String
    expect_database(page) unless page_or_rendered.is_a? String

    expect(page_or_rendered).to have_selector('h1', text: Button::Round::CHOOSE_COURSE)
    courses.each do |course|
      expect(page_or_rendered).to have_link(course.name)
    end
  end

  def expect_rounds_tees(page_or_rendered, course, tees, show_course_tees, show_round_tees)
    expect_aside(page, show_course_tees, show_round_tees) unless page_or_rendered.is_a? String
    expect_database(page) unless page_or_rendered.is_a? String

    expect(page_or_rendered).to have_selector('h1', text: 'Rounds')
    expect(page_or_rendered).to have_selector('h1', text: "Choose Tee for course #{course.name}")

    tees.each do |tee|
      expect(page_or_rendered).to have_link(tee.color)
    end

    expect(page_or_rendered).to have_button(Button::Round::COURSES, count: 0) if page_or_rendered.is_a? String
    expect(page_or_rendered).to have_button(Button::Round::COURSES, count: 1) unless page_or_rendered.is_a? String

    # rubocop:disable Layout/LineLength
    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Course::SHOW_COURSES}']", count: 0) if page_or_rendered.is_a? String
    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Course::SHOW_COURSES}']", count: 1) unless page_or_rendered.is_a? String

    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Round::COURSES}']", count: 0) if page_or_rendered.is_a? String
    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Round::COURSES}']", count: 1) unless page_or_rendered.is_a? String

    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Round::TEES}']", count: 0) if page_or_rendered.is_a? String
    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Round::TEES}']", count: 1) unless page_or_rendered.is_a? String
    # rubocop:enable Layout/LineLength
  end

  def expect_rounds(page_or_rendered, course, tee, rounds, show_course_tees, show_round_tees)
    expect_aside(page, show_course_tees, show_round_tees) unless page_or_rendered.is_a? String
    expect_database(page) unless page_or_rendered.is_a? String
    expect(page_or_rendered).to have_selector('h1', text: "Rounds for #{course.name} and tee #{tee.color}")
    if rounds.empty?
      expect(page_or_rendered).to have_selector('p', text: Label::Round::NO_ROUNDS)
    else
      rounds.each do |round|
        expect(page_or_rendered).to have_link(round.date.to_s)
      end
    end
    expect(page_or_rendered).to have_button(Button::Round::TEES, count: 1) unless page_or_rendered.is_a? String
    expect(page_or_rendered).to have_button(Button::Round::COURSES, count: 0) if page_or_rendered.is_a? String
    expect(page_or_rendered).to have_button(Button::Round::COURSES, count: 1) unless page_or_rendered.is_a? String

    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Round::NEW}']", count: 1)
    expect(page_or_rendered).to have_selector("input[type=submit][value='#{Button::Round::CREATE}']", count: 1)
  end

  def expect_round_form_fields(page_or_rendered, values, update_create)
    expect_aside(page, values[:show_course_tees], values[:show_round_tees]) unless page_or_rendered.is_a? String
    expect_database(page) unless page_or_rendered.is_a? String

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    new_edit = update_create == Button::Round::UPDATE ? Label::Round::EDIT : Label::Round::NEW

    expect(page_or_rendered).to have_selector('h1', count: 1, text: new_edit)
    expect(page_or_rendered).to have_selector('h2', count: 1, text: "Course: #{values[:course_name]}")
    expect(page_or_rendered).to have_selector('h2', count: 1, text: "Tee: #{values[:tee_color]}")
    expect(page_or_rendered).to have_selector("input[type=date][id=round_date][value='#{values[:date]}']", count: 1)
    expect(page_or_rendered).to have_button(update_create, count: 1)
  end

  def expect_show_round_form_fields(page_or_rendered, values)
    disabled = values[:disabled].nil? ? false : values[:disabled]
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    expect(page_or_rendered).to have_selector('h1', count: 1, text: Label::Round::SHOW)
    expect(page_or_rendered).to have_selector('h2', count: 1, text: "Course: #{values[:course_name]}")
    expect(page_or_rendered).to have_selector('h2', count: 1, text: values[:color])
    # rubocop:disable Layout/LineLength
    expect(page_or_rendered).to have_selector("input[type=date][id=round_date][value='#{values[:date]}']", count: 1) unless disabled
    expect(page_or_rendered).to have_selector("input[type=date][id=round_date][disabled=disabled][value='#{values[:date]}']", count: 1) if disabled
    # rubocop:enable Layout/LineLength
  end
end
