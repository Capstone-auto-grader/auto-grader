require 'excon'
class ContainersController < ApplicationController
  before_action :set_container, only: [:show, :edit, :update, :destroy]

  # GET /containers
  # GET /containers.json
  def index
    @containers = Container.all
  end

  # GET /containers/1
  # GET /containers/1.json
  def show
  end

  # GET /containers/new
  def new
    @container = Container.new
  end

  # GET /containers/1/edit
  def edit
  end

  # POST /containers
  # POST /containers.json
  def create
    tar_file = params[:container][:tar_file]
    @container = Container.new(container_params)



    respond_to do |format|
      if @container.save
        obj = S3_BUCKET.object "container-#{@container.id}.tar"
        obj.upload_stream do |stream|
          IO.copy_stream tar_file,stream
        end
        @container.s3_uri = obj.key
        response = Excon.post("#{ENV['GRADING_SERVER']}/containers",
                              headers: {
                                  "Accept" => "application/json",
                                  "Content-Type" => "application/json"
                              },
                              body: {
                                  name: @container.name,
                                  config_uri: obj.key
                              }.to_json)
        @container.update_attribute(:remote_id, JSON.parse(response.body)["id"])
        format.html { redirect_to @container, notice: 'Container was successfully created.' }
        format.json { render :show, status: :created, location: @container }
      else
        format.html { render :new }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    tar_file = params[:container][:tar_file]
    params[:container].delete(:tar_file)
    respond_to do |format|
      if @container.update(container_params)
        if tar_file
          obj = S3_BUCKET.object "container-#{@container.id}.tar"
          obj.upload_stream do |stream|
            IO.copy_stream tar_file,stream
          end
          @container.s3_uri = obj.key
          Excon.patch("#{ENV['GRADING_SERVER']}/containers/#{@container.remote_id}",
                      headers: {
                          "Accept" => "application/json",
                          "Content-Type" => "application/json"
                      },
                      body: {
                          name: @container.name,
                          config_uri: obj.key
                      }.to_json)
        end
        format.html { redirect_to @container, notice: 'Container was successfully updated.' }
        format.json { render :show, status: :ok, location: @container }
      else
        format.html { render :edit }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.json
  def destroy
    @container.destroy
    respond_to do |format|
      format.html { redirect_to containers_url, notice: 'Container was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def container_params
      params.require(:container).permit(:name, :s3_uri)
    end
end
