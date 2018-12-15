
class AssignmentsController < ApplicationController
  include AssignmentsHelper
  include SessionsHelper
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :grades]
  before_action :require_login

  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit
  end

  def grades
    if is_superuser(@assignment.course.id)
      @partition = Grade.where(assignment_id: @assignment.id).sort_by{|g| g.student.name}
    else
      @partition = Grade.where(assignment_id: @assignment.id, ta_id: current_user.id).sort_by{|g| g.student.name}
    end
  end

  def download
    object_name = params[:grade].split("/")[1]
    zip_file = S3_BUCKET.object(object_name)
    send_file zip_file,
              filename: "#{Time.now.to_date}.zip",
              type: "application/zip"
  end

  def update_grade
    Grade.find(params[:grade][:id]).update( ta_grade: params[:grade][:ta_grade].to_i)
    redirect_to assignment_grades_path
  end
  # POST /assignments
  # POST /assignments.json
  def create
    uploader = AttachmentUploader.new
    uploader.store! params[:assignment][:assignment_test]
    buckob = S3_BUCKET.object File.basename(uploader.path)
    buckob.upload_file uploader.path
    p = assignment_params
    file = params[:assignment][:uploaded_file]
    p[:structure] = p[:structure].split(',').map &:strip
    uploader = AttachmentUploader.new
    uploader.store! file
    @assignment = Assignment.new(p)
    @assignment.test_uri = "#{S3_BUCKET.name}/#{buckob.key}"

    respond_to do |format|
      if @assignment.save!
        create_grades_from_assignment @assignment
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
        format.json { render :show, status: :created, location: @assignment }
      else
        format.html { render :new }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1
  # PATCH/PUT /assignments/1.json
  def update
    p = assignment_params
    file = params[:assignment][:uploaded_file]
    p[:structure] = p[:structure].split(",")
    respond_to do |format|
      if @assignment.update(p)
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.html { render :edit }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to assignments_url, notice: 'Assignment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.require(:assignment).permit(:name, :course_id, :assignment_test, :due_date, :structure)
    end
end
