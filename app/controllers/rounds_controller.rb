# frozen_string_literal: true

# Controller for handling CRUD for round
#
class RoundsController < ApplicationController
  # Showing list of Courses
  #   Set @course to the list of rounds
  #
  def index
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
  end

  # Show tees in prep for choosing or creating a round
  #
  def show_tees
    course = Course.find(params[:id])
    @tees = course.sorted_tees
  end
end
