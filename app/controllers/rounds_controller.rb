# frozen_string_literal: true

# Controller for handling CRUD for round
#
class RoundsController < ApplicationController
  # Editing round for a tee
  #
  def edit
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @round = Round.find(params[:id])
  end

  # New round for a tee
  #
  def new
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @round = Round.new
  end

  # create Round
  #
  def create
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    date = params[:round][:date]
    @round = nil
    @round = Round.new(round_params) if date.present?

    if date.present? && @round.present? && @round.errors.empty?
      redirect_to course_tee_rounds_path(@course, @tee), alert: 'Round updated.'
    else
      @round = Round.new
      flash.now[:alert] = 'Validation error(s).' if date.present?
      flash.now[:alert] = 'date cannot blank.' if date.blank?
      render :new
    end
  end

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

  # Update of an existing golf round
  #
  def update
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @round = Round.find(params[:id])
    date = params[:round][:date]

    if date.present? && @round.update(round_params)
      redirect_to course_tee_rounds_path(@course, @tee), alert: 'Round updated.'
    else
      flash.now[:alert] = 'Validation error(s).' if date.present?
      flash.now[:alert] = 'date cannot blank.' if date.blank?
      render :edit
    end
  end

  private

  def round_params
    params.require(:round).permit(:id, :date)
  end
end
