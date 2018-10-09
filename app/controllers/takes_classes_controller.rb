class TakesClassesController < ApplicationController
  before_action :set_takes_class, only: [:show, :edit, :update, :destroy]

  # GET /takes_classes
  # GET /takes_classes.json
  def index
    @takes_classes = TakesClass.all
  end

  # GET /takes_classes/1
  # GET /takes_classes/1.json
  def show
  end

  # GET /takes_classes/new
  def new
    @takes_class = TakesClass.new
  end

  # GET /takes_classes/1/edit
  def edit
  end

  # POST /takes_classes
  # POST /takes_classes.json
  def create
    @takes_class = TakesClass.new(takes_class_params)

    respond_to do |format|
      if @takes_class.save
        format.html { redirect_to @takes_class, notice: 'Takes class was successfully created.' }
        format.json { render :show, status: :created, location: @takes_class }
      else
        format.html { render :new }
        format.json { render json: @takes_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /takes_classes/1
  # PATCH/PUT /takes_classes/1.json
  def update
    respond_to do |format|
      if @takes_class.update(takes_class_params)
        format.html { redirect_to @takes_class, notice: 'Takes class was successfully updated.' }
        format.json { render :show, status: :ok, location: @takes_class }
      else
        format.html { render :edit }
        format.json { render json: @takes_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /takes_classes/1
  # DELETE /takes_classes/1.json
  def destroy
    @takes_class.destroy
    respond_to do |format|
      format.html { redirect_to takes_classes_url, notice: 'Takes class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_takes_class
      @takes_class = TakesClass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def takes_class_params
      params.fetch(:takes_class, {})
    end
end
