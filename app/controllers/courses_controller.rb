# frozen_string_literal: true

# Controller for handling CRUD for course
#
class CoursesController < ApplicationController
  # Showing list of Courses
  #   Set @courses to the list of courses
  #
  def index
    @courses = Course.all
  end

  # Show a golf course for given param :id
  #   Set @course for give :id
  #
  def show
    @course = Course.find(params[:id])
  end

  # Update of an existing golf course
  #   Set @course to passed in params
  #   if Save passes the go to show.html.erb
  #   if fails then back to new
  #
  def update
    @course = Course.find(params[:id])
    case params[:commit]
    when I18n.t('button.tee.create')
      @course_id = params[:id]
      @tee = Tee.new
      render 'tees/new'
    else
      old_number_of_holes = @course.number_of_holes
      if @course.update(course_params)
        @course.update_number_of_holes unless old_number_of_holes == @course.number_of_holes
        redirect_to @course
      else
        render :edit, alert: 'Validation error(s).'
      end
    end
  end

  # Creation of a new golf course
  #   Set @course to Course.new
  #
  def new
    @course = Course.new(name: '...')
  end

  # Creation of a new golf course
  #   Set @course to passed in params
  #   if Save passes the go to show.html.erb
  #   if fails then back to new
  #
  def create
    @course = Course.create(course_params)
    if @course.save
      if @course.tees.empty?
        render :edit
      else
        redirect_to @course
      end
    else
      render :new, alert: 'Validation error(s).'
    end
  end

  # edit of an existing golf course
  #   Set @course to passed in params
  #
  def edit
    @course = Course.find(params[:id])
  end

  # destroy of an existing Course
  #
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    redirect_to root_path
  end

  # Show courses in prep for choosing or creating a round
  #
  def rounds_index
    @courses = Course.all
  end

  private

  def course_params
    params.require(:course).permit(Course.basic_permitted_params.concat([{ address_attributes: Address.basic_permitted_params }]))
  end
end
