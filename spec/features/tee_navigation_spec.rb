require 'common/tee_common'
require 'common/course_common'
feature 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  before(:each) do
  end

  after(:each) do
  end

  scenario 'Navigate to new.html.erb on Tee' do
    @course = FactoryBot.create(:course)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   'George',
                                   '555 Xxx Ave.',
                                   '<nothing>',
                                   'Clarksville',
                                   'IN',
                                   '47529')
    click_button('Create Tee')

    expect_tee_form_fields(
      page,
      Course.find_by(id: @course.id).tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' }
    )
  end

  scenario 'create a new Tee for course' do
    @course = FactoryBot.create(:course, should_fillin_tees: false)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   'George',
                                   '555 Xxx Ave.',
                                   '<nothing>',
                                   'Clarksville',
                                   'IN',
                                   '47529')

    click_button('Create Tee')

    expect_tee_form_fields(
      page,
      @course.tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' }
    )

    fill_in 'Color', with: 'Black'
    fill_in 'Slope', with: '139'
    fill_in 'Rating', with: '71.6'

    click_button('Create Tee')
  end

  scenario 'create a new Tee for course and back to edit course' do
    @course = FactoryBot.create(:course, should_fillin_tees: false)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   'George',
                                   '555 Xxx Ave.',
                                   '<nothing>',
                                   'Clarksville',
                                   'IN',
                                   '47529')

    click_button('Create Tee')

    expect(page).to have_selector('h2', text: 'New tee')

    expect_tee_form_fields(
      page,
      @course.tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' }
    )

    fill_in 'Color', with: 'Black'
    fill_in 'Slope', with: '139'
    fill_in 'Rating', with: '71.6'

    click_button('Create Tee')
    # puts "Edit Tee#{page.html}"
    expect(page).to have_selector('h2', text: 'Edit tee')
    click_button('Edit Course')
    # puts "Edit Course#{page.html}"
    expect(page).to have_selector('h1', text: 'Edit Course')
  end

  scenario 'create a new Tee for course with a validation error' do
    @course = FactoryBot.create(:course, should_fillin_tees: false)
    visit edit_course_path(@course.id)
    expect_edit_fields_with_values(page,
                                   'George',
                                   '555 Xxx Ave.',
                                   '<nothing>',
                                   'Clarksville',
                                   'IN',
                                   '47529')

    click_button('Create Tee')

    expect(page).to have_selector('h2', text: 'New tee')

    expect_tee_form_fields(
      page,
      @course.tees,
      { color: 'White',
        slope: '0.0',
        rating: '0.0',
        number_of_holes: '18' }
    )

    fill_in 'Color', with: 'Black'
    fill_in 'Slope', with: 0.0
    fill_in 'Rating', with: 71.6

    click_button('Create Tee')
    # puts "Edit Tee#{page.html}"
    expect(page).to have_selector('h2', text: 'Edit tee')
    click_button('Edit Course')
    # puts "Edit Course#{page.html}"
    expect(page).to have_selector('h1', text: 'Edit Course')
  end

  # scenario 'Navigate to edit.html.erb on Tee' do
  #   @course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: false)
  #   visit edit_course_path(@course.id)
  #
  #   expect_tee_form_fields(
  #     page,
  #     @course.tees,
  #     { color: 'White',
  #       slope: '0.0',
  #       rating: '0.0',
  #       number_of_holes: '18' }
  #   )
  # end
end
