# frozen_string_literal: true

# Controller for handling CRUD for tee
#
class TeesController < ApplicationController
  # Creation of a new golf course tee
  #
  def create
    @course = Course.find(params[:course_id])
    @tee = @course.tees.create(tee_params)
    if @tee.errors.any?
      flash.now[:alert] = 'Error creating tee'
      render 'tees/new'
    else
      case @course.number_of_holes
      when 9
        @tee.add_9_holes
      when 18
        @tee.add_18_holes
      end
      flash[:notice] = 'tee added'
      render 'tees/edit'
    end
  end

  # Creation of a new golf course tee
  #
  def edit
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:id])
  end

  # Show tees for given @course
  #
  def index
    @course = Course.find(params[:course_id])
  end

  # Creation of a new golf course tee
  #
  def new
    @course = Course.find(params[:course_id])
    @tee = Tee.new
  end

  # Update of a new golf course tee
  #
  def update
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:id])
    @tee.update(tee_params)
    if @tee.errors.any?
      flash.now[:alert] = 'Error updating tee'
      render 'tees/new'
    else
      flash[:notice] = 'tee updated'
      render 'tees/edit'
    end
  end

  # Show tees in prep for choosing or creating a round
  #
  def rounds_tees
    @course = Course.find(params[:course_id])
    @tees = @course.sorted_tees
  end

  private

  def tee_params
    params.require(:tee).permit(:id, :color, :slope, :rating)
  end
end
