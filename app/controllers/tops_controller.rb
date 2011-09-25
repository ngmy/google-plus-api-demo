class TopsController < ApplicationController
  # GET /tops
  # GET /tops.json
  def index
  end

  # GET /tops/1
  # GET /tops/1.json
  def show
    @top = Top.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @top }
    end
  end

  # GET /tops/new
  # GET /tops/new.json
  def new
    @top = Top.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @top }
    end
  end

  # GET /tops/1/edit
  def edit
    @top = Top.find(params[:id])
  end

  # POST /tops
  # POST /tops.json
  def create
    @top = Top.new(params[:top])

    respond_to do |format|
      if @top.save
        format.html { redirect_to @top, notice: 'Top was successfully created.' }
        format.json { render json: @top, status: :created, location: @top }
      else
        format.html { render action: "new" }
        format.json { render json: @top.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tops/1
  # PUT /tops/1.json
  def update
    @top = Top.find(params[:id])

    respond_to do |format|
      if @top.update_attributes(params[:top])
        format.html { redirect_to @top, notice: 'Top was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @top.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tops/1
  # DELETE /tops/1.json
  def destroy
    @top = Top.find(params[:id])
    @top.destroy

    respond_to do |format|
      format.html { redirect_to tops_url }
      format.json { head :ok }
    end
  end
end
