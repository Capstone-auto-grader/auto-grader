class TAsClassesController < ApplicationController
  before_action :set_t_as_class, only: [:show, :edit, :update, :destroy]

  # GET /t_as_classes
  # GET /t_as_classes.json
  def index
    @t_as_classes = TAsClass.all
  end

  # GET /t_as_classes/1
  # GET /t_as_classes/1.json
  def show
  end

  # GET /t_as_classes/new
  def new
    @t_as_class = TAsClass.new
  end

  # GET /t_as_classes/1/edit
  def edit
  end

  # POST /t_as_classes
  # POST /t_as_classes.json
  def create
    @t_as_class = TAsClass.new(t_as_class_params)

    respond_to do |format|
      if @t_as_class.save
        format.html { redirect_to @t_as_class, notice: 'T as class was successfully created.' }
        format.json { render :show, status: :created, location: @t_as_class }
      else
        format.html { render :new }
        format.json { render json: @t_as_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /t_as_classes/1
  # PATCH/PUT /t_as_classes/1.json
  def update
    respond_to do |format|
      if @t_as_class.update(t_as_class_params)
        format.html { redirect_to @t_as_class, notice: 'T as class was successfully updated.' }
        format.json { render :show, status: :ok, location: @t_as_class }
      else
        format.html { render :edit }
        format.json { render json: @t_as_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /t_as_classes/1
  # DELETE /t_as_classes/1.json
  def destroy
    @t_as_class.destroy
    respond_to do |format|
      format.html { redirect_to t_as_classes_url, notice: 'T as class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_t_as_class
      @t_as_class = TAsClass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def t_as_class_params
      params.fetch(:t_as_class, {})
    end
end
