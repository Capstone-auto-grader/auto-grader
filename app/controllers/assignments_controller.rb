class AssignmentsController < ApplicationController
  include AssignmentsHelper
  include SessionsHelper
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :grades, :download_csv, :download_partition, :show_partition]
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

  def upload_submissions
    uploader = AttachmentUploader.new
    uploader.store! params[:assignment][:subm_file]
    @assignment = Assignment.find(params[:assignment][:id])
    if @assignment.submitted_once
      @assignment.submissions.where(grade_received: false).update_all(late_penalty: 20)
    else
      @assignment.update(submitted_once: true)
    end
    respond_to do |format|
      UploadZipFileJob.perform_later uploader.filename, @assignment.id
      format.html { redirect_to assignment_grades_path(@assignment.id), notice: 'Assignment submissions were successfully uploaded' }
      format.json { render :show, status: :created, location: @assignment }
    end
  end

  def grades
    if is_superuser(@assignment.course.id)
      @partition = @assignment.submissions.sort_by{|s| s.student.name}
    else
      @partition = Submission.where(assignment_id: @assignment.id, ta_id: current_user.id).sort_by{|s| s.student.name}
    end
    @grades_remaining = @partition.reject { |s| s.grade_received || s.zip_uri.nil? }.count
  end

  def show_partition
  end

  def download_partition
    object_name = SubmissionBatch.find_by(user_id: current_user.id, assignment: @assignment).zip_uri

    zip_file = S3_BUCKET.object(object_name).presigned_url(:get, expires_in: 60)
    send_data open(zip_file).read,
              filename: "#{object_name}",
              type: "application/zip",
              disposition: 'attachment',
              stream: 'true',
              buffer_size: '4096'
  end

  def download
    object_name = params[:grade].split("/")[1]
    zip_file = S3_BUCKET.object(object_name).presigned_url(:get, expires_in: 60)
    send_data open(zip_file).read,
              filename: "#{Time.now.to_date}.zip",
              type: "application/zip",
              disposition: 'attachment',
              stream: 'true',
              buffer_size: '4096'
  end

  def update_grade
    params[:submissions].keys.each do |id|
      submission_params = params[:submissions][id]
      ta_grade = submission_params[:ta_grade]
      ta_grade = ta_grade.to_i unless ta_grade.nil?
      ta_comment = submission_params[:ta_comment]
      Submission.find(id).update(ta_grade: ta_grade, ta_comment: ta_comment)
    end
    redirect_to assignment_grades_path
  end

  def download_csv
    @submissions = @assignment.submissions
    @submissions = @submissions.where.not(ta_grade: nil) unless @assignment.test_grade_weight == 100
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"AutoGrader_#{@assignment.name}.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # POST /assignments
  # POST /assignments.json
  def create
    uploader = AttachmentUploader.new
    uploader.store! params[:assignment][:assignment_test]
    base = Tempfile.new
    base.binmode
    base.write params[:assignment][:base_uri].read
    base.rewind
    base_obj = S3_BUCKET.object File.basename(base.path)
    base_obj.upload_file base.path

    buckob = S3_BUCKET.object File.basename(uploader.path)
    buckob.upload_file uploader.path
    p = assignment_params
    ec_hash = Hash.new
    p[:extra_credit].remove("\r").split("\n").each do |line|
      pair = line.split(', ')
      ec_hash[pair[0]] = pair[1].to_i
    end
    p[:extra_credit] = ec_hash
    p[:group_offset] = get_group_offset(p[:course_id])
    file = params[:assignment][:uploaded_file]
    p[:submitted_once] = false
    uploader = AttachmentUploader.new
    uploader.store! file
    p[:test_uri] = "#{S3_BUCKET.name}/#{buckob.key}"
    @assignment = Assignment.new(p)

    respond_to do |format|
      if @assignment.save!
        resubmit_params = p.clone
        resubmit_params[:name] = "#{p[:name]} RESUBMIT"
        resubmit = Assignment.new(resubmit_params)
        resubmit.save!
        @assignment.resubmit = resubmit
        @assignment.save!
        @orig_csv = CSV.read(params[:assignment][:orig_csv].path)
        @resub_csv = CSV.read(params[:assignment][:resub_csv].path)
        create_submissions_from_assignment @assignment, @orig_csv, @resub_csv
        format.html { redirect_to course_path(@assignment.course), notice: 'Assignment was successfully created.' }
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
      params.require(:assignment).permit(:name, :course_id, :assignment_test, :extra_credit, :test_uri, :base_uri, :test_grade_weight, :submitted_once)
    end
end
