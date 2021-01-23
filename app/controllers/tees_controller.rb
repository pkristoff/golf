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
      @tee = Tee.new
      flash[:notice] = 'tee added'
      render 'tees/edit'
    end
  end

  # Creation of a new golf course tee
  #
  def edit
    @course = Course.find(params[:course_id])
    @tee = Tee.new
  end

  # Creation of a new golf course tee
  #
  def new
    @course = Course.find(params[:course_id])
    @tee = Tee.new
  end

  private

  def tee_params
    params.require(:tee).permit(:color, :slope, :rating)
  end
end
