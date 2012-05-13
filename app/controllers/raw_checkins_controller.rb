class RawCheckinsController < ApplicationController
  # GET /raw_checkins
  # GET /raw_checkins.json
  def index
    @raw_checkins = RawCheckin.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @raw_checkins }
    end
  end

  # GET /raw_checkins/1
  # GET /raw_checkins/1.json
  def show
    @raw_checkin = RawCheckin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @raw_checkin }
    end
  end

  # GET /raw_checkins/new
  # GET /raw_checkins/new.json
  def new
    @raw_checkin = RawCheckin.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @raw_checkin }
    end
  end

  # GET /raw_checkins/1/edit
  def edit
    @raw_checkin = RawCheckin.find(params[:id])
  end

  # POST /raw_checkins
  # POST /raw_checkins.json
  def create
    @raw_checkin = RawCheckin.new(params[:raw_checkin])

    respond_to do |format|
      if @raw_checkin.save
        format.html { redirect_to @raw_checkin, notice: 'Raw checkin was successfully created.' }
        format.json { render json: @raw_checkin, status: :created, location: @raw_checkin }
      else
        format.html { render action: "new" }
        format.json { render json: @raw_checkin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /raw_checkins/1
  # PUT /raw_checkins/1.json
  def update
    @raw_checkin = RawCheckin.find(params[:id])

    respond_to do |format|
      if @raw_checkin.update_attributes(params[:raw_checkin])
        format.html { redirect_to @raw_checkin, notice: 'Raw checkin was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @raw_checkin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /raw_checkins/1
  # DELETE /raw_checkins/1.json
  def destroy
    @raw_checkin = RawCheckin.find(params[:id])
    @raw_checkin.destroy

    respond_to do |format|
      format.html { redirect_to raw_checkins_url }
      format.json { head :ok }
    end
  end
end
