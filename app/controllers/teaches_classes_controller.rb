class TeachesClassesController < ApplicationController
  before_action :set_teaches_class, only: [:show, :edit, :update, :destroy]

  # GET /teaches_classes
  # GET /teaches_classes.json
  def index
    @teaches_classes = TeachesClass.all
  end

  # GET /teaches_classes/1
  # GET /teaches_classes/1.json
  def show
  end

  # GET /teaches_classes/new
  def new
    @teaches_class = TeachesClass.new
  end

  # GET /teaches_classes/1/edit
  def edit
  end

  # POST /teaches_classes
  # POST /teaches_classes.json
  def create
    @teaches_class = TeachesClass.new(teaches_class_params)

    respond_to do |format|
      if @teaches_class.save
        format.html { redirect_to @teaches_class, notice: 'Teaches class was successfully created.' }
        format.json { render :show, status: :created, location: @teaches_class }
      else
        format.html { render :new }
        format.json { render json: @teaches_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teaches_classes/1
  # PATCH/PUT /teaches_classes/1.json
  def update
    respond_to do |format|
      if @teaches_class.update(teaches_class_params)
        format.html { redirect_to @teaches_class, notice: 'Teaches class was successfully updated.' }
        format.json { render :show, status: :ok, location: @teaches_class }
      else
        format.html { render :edit }
        format.json { render json: @teaches_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teaches_classes/1
  # DELETE /teaches_classes/1.json
  def destroy
    @teaches_class.destroy
    respond_to do |format|
      format.html { redirect_to teaches_classes_url, notice: 'Teaches class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teaches_class
      @teaches_class = TeachesClass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def teaches_class_params
      params.fetch(:teaches_class, {})
    end
end
