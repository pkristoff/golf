require 'common/tee_common'
require 'common/hole_common'
require 'common/course_common'
feature 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  include HoleCommon
  before(:each) do
  end

  after(:each) do
  end

  scenario 'Navigate to new.html.erb on Tee' do
    @course = FactoryBot.create(:course)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   name: 'George',
                                   street_1: '555 Xxx Ave.',
                                   street_2: '<nothing>',
                                   city: 'Clarksville',
                                   state: 'IN',
                                   zip: '47529')
    click_button(Button::Tee::NEW)

    expect_tee_form_fields(
      page,
      Course.find_by(id: @course.id).tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' },
      'Create'
    )
  end

  scenario 'create a new Tee for course' do
    @course = FactoryBot.create(:course, should_fillin_tees: false)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   name: 'George',
                                   street_1: '555 Xxx Ave.',
                                   street_2: '<nothing>',
                                   city: 'Clarksville',
                                   state: 'IN',
                                   zip: '47529')

    click_button(Button::Tee::NEW)

    expect_tee_form_fields(
      page,
      @course.tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' },
      'Create'
    )

    fill_in Label::Tee::COLOR, with: 'Black'
    fill_in Label::Tee::SLOPE, with: '139'
    fill_in Label::Tee::RATING, with: '71.6'

    click_button(Button::Tee::CREATE)
  end

  scenario 'create a new Tee for course and back to edit course' do
    @course = FactoryBot.create(:course, should_fillin_tees: false)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   name: 'George',
                                   street_1: '555 Xxx Ave.',
                                   street_2: '<nothing>',
                                   city: 'Clarksville',
                                   state: 'IN',
                                   zip: '47529')

    click_button(Button::Tee::NEW)

    expect_tee_form_fields(
      page,
      @course.tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' },
      'Create'
    )

    fill_in Label::Tee::COLOR, with: 'Black'
    fill_in Label::Tee::SLOPE, with: '139'
    fill_in Label::Tee::RATING, with: '71.6'

    click_button(Button::Tee::CREATE)
    expect(page).to have_selector('h1', text: 'Edit tee:')
    click_button(Button::Course::EDIT)
    expect(page).to have_selector('h1', text: 'Edit Course')
  end

  scenario 'create a new Tee for course with a validation error' do
    @course = FactoryBot.create(:course, should_fillin_tees: false)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   name: 'George',
                                   street_1: '555 Xxx Ave.',
                                   street_2: '<nothing>',
                                   city: 'Clarksville',
                                   state: 'IN',
                                   zip: '47529')

    click_button(Button::Tee::NEW)

    expect_tee_form_fields(
      page,
      @course.tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' },
      'Create'
    )

    fill_in Label::Tee::COLOR, with: 'Black'
    fill_in Label::Tee::SLOPE, with: 0.0
    fill_in Label::Tee::RATING, with: 71.6

    click_button(Button::Tee::CREATE)
    # puts "Edit Tee#{page.html}"
    expect(page).to have_selector('h1', text: 'Edit tee:')
    click_button(Button::Course::EDIT)
    # puts "Edit Course#{page.html}"
    expect(page).to have_selector('h1', text: 'Edit Course')
  end

  scenario 'Navigate to edit.html.erb on Tee with no holes' do
    @course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: false)
    visit edit_course_path(@course.id)

    expect_edit_fields_with_values(page,
                                   name: 'George',
                                   street_1: '555 Xxx Ave.',
                                   street_2: '<nothing>',
                                   city: 'Clarksville',
                                   state: 'IN',
                                   zip: '47529')

    click_link('Black')

    expect_tee_form_fields(
      page,
      @course.tees,
      { color: 'Black',
        slope: '139.0',
        rating: '71.6',
        number_of_holes: '18' },
      'Update'
    )

    expect_holes(page, [], [])

  end

end
