# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'courses/index.html.erb', type: :view do
  it 'index with zero course' do
    assign(:courses, [])

    render

    expect(rendered).to have_selector("li[id='li-id']", count: 0)
    expect(rendered).to have_selector("a[id='add_new_course']", text: 'Add new Course')
  end

  it 'index with one course' do
    course = FactoryBot.create(:course)
    assign(:courses, [course])

    render

    expect(rendered).to have_selector("li[id='li-id']", count: 1)
    expect(rendered).to have_selector("a[id='edit_link_#{course.id}']", text: 'George')
    expect(rendered).to have_selector("a[id='add_new_course']", text: 'Add new Course')
  end
end
