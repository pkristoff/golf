# frozen_string_literal: true

require 'common/course_common'
describe 'add a new course' do
  include CourseCommon
  # include ViewsHelpers
  # before(:each) do
  # end
  #
  # after(:each) do
  # end

  it 'visit new course' do
    visit new_course_path

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18',
                                   street1: '', street2: '', city: '', state: '', zip_code: '27502')
  end

  it 'visit new course fill in invalid values &look for errors' do
    visit new_course_path
    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18', street1: '', street2: '',
                                   city: '', state: '', zip_code: '27502')

    fill_in I18n.t('activerecord.attributes.course.name'), with: ''
    fill_in I18n.t('activerecord.attributes.course.number_of_holes'), with: 0
    fill_in I18n.t('activerecord.attributes.course.address/address.zip_code'), with: ''

    click_button(I18n.t('button.course.submit'))

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '',
                                   number_of_holes: '0', street1: '', street2: '', city: '', state: '', zip: '')

    CourseCommon.expect_validation_errors(page, %w[
                                            course_name
                                            course_address_attributes_street1
                                            course_address_attributes_city
                                            course_address_attributes_state
                                            course_address_attributes_zip_code
                                          ],
                                          %w[
                                            course_address_attributes_street2
                                          ])
  end

  it 'visit new course fill in valid values it should render index.html.erb' do
    visit new_course_path
    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...', number_of_holes: '18',
                                   street1: '', street2: '', city: '', state: '', zip_code: '27502')

    fill_in I18n.t('activerecord.attributes.course.name'), with: 'Lochmere'

    fill_in I18n.t('activerecord.attributes.course.address/address.street1'), with: '2116 Frissell Ave.'
    fill_in I18n.t('activerecord.attributes.course.address/address.street2'), with: ''
    fill_in I18n.t('activerecord.attributes.course.address/address.city'), with: 'Apex'
    fill_in I18n.t('activerecord.attributes.course.address/address.state'), with: 'NC'
    fill_in I18n.t('activerecord.attributes.course.address/address.zip_code'), with: '27502'

    click_button(I18n.t('button.course.submit'))

    expect(Course.all.size).to eq(1)

    course = Course.all.first
    # no tees defined so go to edit
    CourseCommon.expect_edit_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    course_name: 'Lochmere',
                                    number_of_holes: '18',
                                    street1: '2116 Frissell Ave.',
                                    street2: '',
                                    city: 'Apex',
                                    state: 'NC',
                                    zip_code: '27502')

    CourseCommon.expect_validation_errors(
      page,
      %w[],
      %w[
        course_name
        course_address_attributes_street1
        course_address_attributes_street2
        course_address_attributes_city
        course_address_attributes_state
        course_address_attributes_zip_code
      ]
    )

    click_button(I18n.t('button.tee.new'))

    expect(Course.all.size).to eq(1)

    course = Course.all.first

    TeeCommon.expect_new_tee(page,
                             course,
                             course.tees,
                             { course_name: course.name,
                               tee_color: 'White',
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })

    fill_in I18n.t('activerecord.attributes.tee.slope'), with: 140.0
    fill_in(I18n.t('activerecord.attributes.tee.rating'), with: 75.0)

    click_button(I18n.t('button.tee.create'))

    click_button(I18n.t('button.course.edit'))

    click_button(I18n.t('button.course.update'))

    CourseCommon.expect_show_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    course_name: 'Lochmere',
                                    number_of_holes: '18',
                                    street1: '2116 Frissell Ave.',
                                    street2: '',
                                    city: 'Apex',
                                    state: 'NC',
                                    zip_code: '27502')
  end
end
