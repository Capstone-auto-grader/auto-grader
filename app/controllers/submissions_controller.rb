class SubmissionsController < ApplicationController
  include AssignmentsHelper
  before_action :set_submission, only: [:show, :edit, :update, :destroy]
  before_action :require_login
  before_action :verify_superuser, only: [:edit, :update]
  skip_before_action :verify_authenticity_token
  # GET /submissions
  # GET /submissions.json
  def index
    if params.key? :assignment_id
      @submissions = Submission.where(assignment_id: params[:assignment_id])
    else
      @submissions = Submission.where(user_id: current_user.id)
    end
    if @submissions.is_a?(FalseClass)
      @submissions = []
    end

  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
    @assignment = Assignment.find(params[:assignment_id].to_i)
    # A change to submit
  end

  # GET /submissions/1/edit
  def edit
  end

  def verify_superuser
    redirect_to assignment_grades_path(@submission.assignment.id) unless is_superuser(@submission.assignment.course.id)
  end

  # POST /submissions
  # POST /submissions.json
  def create
    # TODO: Make sure user can have multiple submissions per assignment
    uploader = AttachmentUploader.new
    uploader.store! params[:submission][:subm_file]
    #TODO: REPLACE WITH CURRENT USER
    @submission = Submission.new(course_id: params[:course_id].to_i, user_id: current_user.id)
    @submission.assignment = Assignment.find(params[:assignment_id])
    respond_to do |format|
      if @submission.save!
        #TODO: WE NEED TO TEST THIS
        puts "OK"
        UploadBulkZipFileJob.perform_later uploader.filename,@submission.assignment.id
        format.html { redirect_to course_path(@submission.assignment.course_id),notice: 'Submission was successfully created.' }
        format.json { render :show, status: :created, location: @submission }
      else
        format.html { render :new }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /submissions/1
  # PATCH/PUT /submissions/1.json
  def update
    old_ta_id = @submission.ta.id
    if(! params[:submission][:subm_file].nil?)
      uploader = AttachmentUploader.new
      uploader.store! params[:submission][:subm_file]
      byebug
      UploadIndividualZipFileJob.perform_later uploader.filename,@submission.assignment.id
    else
      puts "NO FILE"
    end
    submission_params[:ta_id] = submission_params[:ta_id].to_i

    if submission_params[:final_grade_override].to_i.zero?
      @submission.update(final_grade_override: nil)
      params[:submission].delete(:final_grade_override)
    end

    if submission_params[:comment_override].nil? || submission_params[:comment_override].empty?
      @submission.update(comment_override: nil)
      params[:submission].delete(:comment_override)
    end

    respond_to do |format|
      if @submission.update(submission_params)
        unless old_ta_id == @submission.ta.id
          [User.find(old_ta_id), @submission.ta].each do |ta|
            create_zip_from_batch @submission.assignment.id, ta.id
          end
        end
        format.html { redirect_to assignment_grades_path(@submission.assignment_id), notice: 'Submission was successfully updated.' }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to submissions_url, notice: 'Submission was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:ta_id, :subm_file, :tests_passed, :total_tests, :ta_grade, :is_valid, :late_penalty, :extra_credit_points, :final_grade_override, :ta_comment, :comment_override)
    end
end
