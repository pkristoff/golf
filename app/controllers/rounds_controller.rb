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
    params[:round][:tee_id] = params[:tee_id]
    date = params[:round][:date]
    @round = nil
    @round = Round.create(round_params) if date.present?
    if date.present? && @round.present? && @round.errors.empty?
      redirect_to course_tee_round_path(@course, @tee, @round), alert: t('flash.alert.round')
    else
      # @round = Round.new
      flash.now[:alert] = t('flash.alert.validation') if date.present?
      flash.now[:alert] = t('flash.alert.date') if date.blank?
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

  # Show a round for given course and tee
  #   Set @course for give :course_id
  #   Set @tee for give :tee_id
  #
  def show
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @round = Round.find(params[:id])
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
      redirect_to course_tee_rounds_path(@course, @tee), alert: t('flash.alert.round')
    else
      flash.now[:alert] = t('flash.alert.validation') if date.present?
      flash.now[:alert] = t('flash.alert.date') if date.blank?
      render :edit
    end
  end

  private

  def round_params
    params.require(:round).permit(:id, :date, :tee_id)
  end
end
