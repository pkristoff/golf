# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'

module CourseCommon
  include AsideCommon
  include DatabaseCommon
  include ButtonToCommon

  def expect_course_index(page_or_rendered, courses)
    expect(page_or_rendered).to have_selector('h1', text: 'Courses')
    expect(rendered).to have_selector("li[id='li-id']", count: courses.size)
    if courses.empty?
      expect(page_or_rendered).to have_selector('h2', text: 'No courses')
    else
      courses.each do |course|
        expect(rendered).to have_selector("a[id='edit_link_#{course.id}']", text: course.name)
      end
    end
    expect_other_buttons(page_or_rendered)
  end

  def expect_other_buttons(page_or_rendered)
    expect_button_within_course_fieldset(page_or_rendered, [Button::Course::NEW])
    expect_button_within_round_fieldset(page_or_rendered, [])
  end

  def expect_new_fields_with_values(page, values = {})
    expect_aside(page, values[:show_tees])
    expect_database(page)

    expect(page).to have_selector('h1', text: 'New Course')
    expect(find_button('submit-course')).to be_truthy
    expect(find_field(Label::Course::NAME).value).to eq(values[:name])
    expect(find_field(Label::Course::NUMBER_OF_HOLES).value).to eq(values[:number_of_holes])
    expect(find_field(Label::Course::STREET1).value).to eq(values[:street_1])
    expect(find_field(Label::Course::STREET2).value).to eq(values[:street_2])
    expect(find_field(Label::Course::CITY).value).to eq(values[:city])
    expect(find_field(Label::Course::STATE).value).to eq(values[:state])
    expect(find_field(Label::Course::ZIP).value).to eq(values[:zip])
    expect(find_button(Button::Course::CREATE)).to be_truthy
    # rubocop:disable Layout/LineLength
    expect { find_button(Button::Tee::CREATE) }.to raise_error(Capybara::ElementNotFound, 'Unable to find button "Create Tee" that is not disabled')
    # rubocop:enable Layout/LineLength
  end

  def expect_validation_errors(invalid_field_names, valid_field_names)
    invalid_field_names.each do |field_name|
      expect(page).to have_selector("div[class=field_with_errors] input[id=#{field_name}]")
    end
    valid_field_names.each do |field_name|
      expect(page).not_to have_selector("div[class=field_with_errors] input[id=#{field_name}]")
    end
  end

  def expect_edit_fields_with_values(page, values = {})
    expect_aside(page, values[:show_tees])
    expect_database(page)

    expect(page).to have_selector('h1', text: 'Edit Course')
    expect(find_button('submit-course')).to be_truthy
    expect(find_field(Label::Course::NAME).value).to eq(values[:name])
    expect(find_field(Label::Course::STREET1).value).to eq(values[:street_1])
    expect(find_field(Label::Course::STREET2).value).to eq(values[:street_2])
    expect(find_field(Label::Course::CITY).value).to eq(values[:city])
    expect(find_field(Label::Course::STATE).value).to eq(values[:state])
    expect(find_field(Label::Course::ZIP).value).to eq(values[:zip])
    expect(find_button(Button::Course::UPDATE)).to be_truthy
    expect(find_button(Button::Tee::NEW)).to be_truthy
  end

  def expect_show_fields_with_values(page, values = {})
    expect_aside(page, values[:show_tees])
    expect_database(page)

    expect(page).to have_selector('h1', text: 'Show Course')

    expect(find_button(Label::Common::EDIT)).to be_truthy
    expect(find_button(Label::Course::DESTROY)).to be_truthy
    expect(find_button(Button::Course::SHOW_COURSES, count: 1)).to be_truthy
    expect(find_field(Label::Course::NAME, disabled: true).value).to eq(values[:name])
    expect(find_field(Label::Course::STREET1, disabled: true).value).to eq(values[:street_1])
    expect(find_field(Label::Course::STREET2, disabled: true).value).to eq(values[:street_2])
    expect(find_field(Label::Course::CITY, disabled: true).value).to eq(values[:city])
    expect(find_field(Label::Course::STATE, disabled: true).value).to eq(values[:state])
    expect(find_field(Label::Course::ZIP, disabled: true).value).to eq(values[:zip])
  end

  def expect_form_fields(disabled, button_name, values)
    # expect_aside(rendered)

    expect(rendered).to have_field('course_name', disabled: disabled)
    expect(rendered).to have_selector("input[id=course_name][value='#{values[:course_name]}']")
    expect(rendered).to have_field(Label::Course::STREET1, disabled: disabled)
    # rubocop:disable Layout/LineLength
    expect(rendered).to have_selector("input[id=course_address_attributes_street_1][value='#{values[:course_address_attributes_street_1]}']")
    expect(rendered).to have_field(Label::Course::STREET2, disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_street_2][value='#{values[:course_address_attributes_street_2]}']")
    expect(rendered).to have_field(Label::Course::CITY, disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_city][value='#{values[:course_address_attributes_city]}']")
    expect(rendered).to have_field(Label::Course::STATE, disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_state][value='#{values[:course_address_attributes_state]}']")
    expect(rendered).to have_field(Label::Course::ZIP, disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_zip_code][value='#{values[:course_address_attributes_zip_code]}']")
    # rubocop:enable Layout/LineLength

    expect(rendered).to have_button(button_name) unless disabled
    expect(rendered).not_to have_button(button_name) if disabled
    expect(rendered).to have_button(Button::Tee::NEW) if !disabled && button_name == Button::Course::UPDATE
    expect(rendered).not_to have_button(Button::Tee::NEW) if disabled && !button_name == Button::Course::UPDATE
    expect(rendered).not_to have_button(Button::Course::SHOW_COURSES)
  end
end
