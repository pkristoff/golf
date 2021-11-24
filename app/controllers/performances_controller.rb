# frozen_string_literal: true

# A PerformancesController
#
class PerformancesController < ApplicationController
  # Show the performance data for a tee
  #
  def index
    @course = Course.find_by(id: params[:course_id])
    @tee = Tee.find_by(id: params[:tee_id])
    @performance = PerformanceCourse.new(@tee, @course.number_of_holes)
  end
end
