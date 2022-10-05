# frozen_string_literal: true

# AsideCommon - stuff on the side of the screen
#
module AsideCommon
  class << self
    include RSpec::Matchers # enable_expect

    # expect buttons in a sidebar
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:show_tees</tt> whether to show I18n.t('button.course.show_tees') button.
    #
    def expect_aside(rendered_or_page, show_tees)
      raise('show_round_tees not set') if show_tees.nil?
      raise('show_course_tees not set') if show_tees.nil?

      ButtonToCommon.expect_side_bar_button(rendered_or_page, I18n.t('button.course.show_courses'))
      ButtonToCommon.expect_side_bar_button(rendered_or_page, I18n.t('button.round.show_courses'))
      ButtonToCommon.expect_side_bar_button(rendered_or_page, I18n.t('button.course.show_tees')) if show_tees
      ButtonToCommon.expect_no_side_bar_button(rendered_or_page, I18n.t('button.course.show_tees')) unless show_tees
    end
  end
end

# DatabaseCommon - menu dropdown
#
module DatabaseCommon
  class << self
    include RSpec::Matchers

    # expect menu for importing data & clear db
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    #
    def expect_menu(rendered_or_page)
      expect(rendered_or_page).to have_selector('a[id=account]', text: I18n.t('activerecord.models.account'), count: 1)
      expect(rendered_or_page).to have_selector('ul[class=dropdown-menu] a[id=clear_db]',
                                                text: I18n.t('label.menu.clear'),
                                                count: 1)
      expect(rendered_or_page).to have_selector('ul[class=dropdown-menu] a[id=load_in_xsxl_file]',
                                                text: I18n.t('label.menu.load_xsxl'),
                                                count: 1)
    end
  end
end
