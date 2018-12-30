class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :require_login
  # GET /courses
  # GET /courses.json
  def index
    @current_user = current_user
    if !@current_user.professorships.empty?
      @courses = @current_user.professorships
    elsif !@current_user.taships.empty?
      redirect_to ta_index_path
    end
  end

  def ta_index
    @courses = @current_user.taships
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    if is_superuser(params[:id])
      @assignments= @course.assignments.order(:created_at)
      @recently_edited = @assignments[-2]
      render 'courses/show_professor'
    elsif is_ta(params[:id])
      @assignments= @course.assignments.order(:created_at)
      @recently_edited = @assignments[-2]
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
    @assignments= @course.assignments.order(:created_at).reverse
    @recently_edited = @assignments.first
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
      @add_failed = true
      render 'get_ta'
    else
      @ta = User.where(email: params[:email]).first
      if @course.tas.where(id: @ta.id).size == 0
        @course.tas << @ta
        @successful = true
        render 'get_ta'
      else
        @add_ta_already = true
        render 'get_ta'
      end
    end
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
      render 'get_student'
    else
      @add_student_already = true
      render 'get_student'
    end
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
      params.require(:course).permit(:name)
    end
end
