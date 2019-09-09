class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :conflict_add, :conflict_remove]
  before_action :require_login
  require 'securerandom'
  # GET /courses
  # GET /courses.json
  def index
    @current_user = current_user
    if !@current_user.professorships.empty?
      @courses = @current_user.professorships
    elsif !@current_user.taships.empty?
      @courses = @current_user.taships
    end
    if @courses
      redirect_to @courses.first if @courses.count == 1
    end

  end

  def conflict_add
    current_user.conflict_students << Student.find(params[:student].first.to_i) unless params[:student].first.empty?
    @conflict_students = current_user.conflict_students
    @non_conflict_students = @course.students - @conflict_students

    respond_to do |format|
      format.js
    end
  end

  def conflict_remove
    TaConflict.where(conflict_ta: current_user, conflict_student: params[:student]).first.destroy
    @conflict_students = current_user.conflict_students
    @non_conflict_students = @course.students - @conflict_students

    respond_to do |format|
      format.js
    end
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    if is_superuser(params[:id])
      @assignments= @course.assignments.order(:created_at)
      @recently_edited = @assignments[-2]
      if is_ta(@course.id)
        @conflict_students = current_user.conflict_students
        @non_conflict_students = @course.students - @conflict_students
      end
      render 'courses/show_professor'
    elsif is_ta(params[:id])
      @assignments= @course.assignments.order(:created_at)
      @recently_edited = @assignments[-2]
      show_ta
      render 'courses/show_ta'
    else
      render 'courses/show'
    end

  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  def show_teacher
    @assignments= @course.assignments.order(:created_at).reverse
    @recently_edited = @assignments.first


  end

  def show_ta
    @assignments = @course.assignments.order(:created_at).reverse
    @recently_edited = @assignments.first

    @conflict_students = current_user.conflict_students
    @non_conflict_students = @course.students - @conflict_students
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_ta
    @ta = User.new
    set_course
  end

  def add_ta
    set_course
    if User.where(email: params[:email]).size == 0
      # @add_failed = true
      user = User.new(email: params[:email], password: SecureRandom.uuid, name: params[:name])
      if user.save
        user.send_invite_email
        @course.tas << user
        @successful = true
      else
        @add_failed = true
      end
    else
      @ta = User.where(email: params[:email]).first
      if @course.tas.where(id: @ta.id).size == 0
        @course.tas << @ta
        @successful = true
      else
        @add_ta_already = true
      end
    end
    render 'get_ta'
  end

  def get_student
    @student = User.new
    set_course
  end

  def add_student
    set_course
    @student = Student.find_or_create_by(email: params[:email])
    if @course.students.where(id: @student.id).size == 0
      @course.students << @student
      @successful = true;
    else
      @add_student_already = true
    end
    render 'get_student'
  end

  def delete_ta
    set_course
    @ta = User.where(email: params[:email]).first
    @course.tas = @course.tas.reject{|user| user == @ta }
    redirect_to edit_course_path
  end

  def delete_student
    set_course
    @student = User.where(email: params[:email]).first
    @course.students = @course.students.reject{|user| user == @student }
    redirect_to edit_course_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.require(:course).permit(:name, :s3_bucket)
    end
end
