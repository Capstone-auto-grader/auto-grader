class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :edit, :update, :destroy]
  before_action :require_login
  # GET /submissions
  # GET /submissions.json
  def index
    @submissions = params.key? :assignment_id ?
                                   Submission.where(assignment_id: params[:assignment_id]) :
                                   Submission.where(user_id: current_user.id)


  end

  # GET /submissions/1
  # GET /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
    @assignment = Assignment.find(params[:assignment_id].to_i)
  end

  # GET /submissions/1/edit
  def edit
  end

  # POST /submissions
  # POST /submissions.json
  def create
    # TODO: Make sure user can have multiple submissions per assignment
    uploader = AttachmentUploader.new
    uploader.store! params[:submission][:subm_file]
    #TODO: REPLACE WITH CURRENT USER
    @submission = Submission.new(course_id: params[:course_id].to_i, user_id: 1)
    @submission.assignment = Assignment.find(params[:assignment_id])
    respond_to do |format|
      if @submission.save!
        #TODO: WE NEED TO TEST THIS
        ValidateZipFileJob.perform_later uploader.filename,@submission.id
        format.html { redirect_to '/submissions', notice: 'Submission was successfully created.' }
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
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission, notice: 'Submission was successfully updated.' }
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
      params.require(:submission).permit(:subm_file)
    end
end
