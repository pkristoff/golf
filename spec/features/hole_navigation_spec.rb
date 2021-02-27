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

  scenario 'Navigate course to tee to holes, then edit hole' do
    @course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: true)
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

    fill_in 'Slope', with: 140.0
    fill_in('Rating', with: 75.0)
    click_button('Update Tee')

    @course = Course.find(@course.id)

    expect_tee_form_fields(
      page,
      @course.tees,
      { expect_messages: [[:flash_notice, 'tee updated']],
        color: 'Black',
        slope: '140.0',
        rating: '75.0',
        number_of_holes: '18' },
      'Update'
    )

    expect_holes(page, @course.tee('Black').sorted_holes, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])
    hole_id = @course.tee('Black').sorted_holes.first.id
    click_link("hole-number-link-#{hole_id}")

    @course = Course.find(@course.id)
    expect_holes(page, @course.tee('Black').sorted_holes, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])

    expect_form_holes(page,
                      expect_messages: [[:flash_notice, 'tee updated']],
                      number: '1', yardage: '411', par: '4', hdcp: '9')

    fill_in 'Yardage', with: 644
    fill_in 'Par', with: 5
    fill_in 'Hdcp', with: 10

    click_button('Update Hole')

    expect_form_holes(page,
                      expect_messages: [[:flash_notice, 'hole updated']],
                      number: '2', yardage: '360', par: '4', hdcp: '15')
  end
end
