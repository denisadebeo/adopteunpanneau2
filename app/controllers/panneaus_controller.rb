class PanneausController < ApplicationController
  before_action :set_panneau, only: [:show, :edit, :update, :destroy]
  before_action :set_panneaus, only: [:index, :get_nearest_pannel]
  # GET /panneaus
  # GET /panneaus.json
  def index
    lat = params[:lat]
    long = params[:long]
    is_ok = params[:is_ok]
    id_panneaux = params[:id_panneaux]  
    if id_panneaux && lat && long
      @panneau = @panneaus.find(id_panneaux.to_i)
      if is_ok != "false"
        @panneau.update(:is_ok=> true)
      else
        @panneau.update(:is_ok=> false)
      end
    end

  end

  # GET /panneaus/1
  # GET /panneaus/1.json
  def show
  end

  # GET /panneaus/new
  def new
    @panneau = Panneau.new
  end

  # GET /panneaus/1/edit
  def edit
  end

  # POST /panneaus
  # POST /panneaus.json
  def create
    @panneau = Panneau.new(panneau_params)

    respond_to do |format|
      if @panneau.save
        format.html { redirect_to @panneau, notice: 'Panneau was successfully created.' }
        format.json { render :show, status: :created, location: @panneau }
      else
        format.html { render :new }
        format.json { render json: @panneau.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /panneaus/1
  # PATCH/PUT /panneaus/1.json
  def update
    respond_to do |format|
      if @panneau.update(panneau_params)
        format.html { redirect_to @panneau, notice: 'Panneau was successfully updated.' }
        format.json { render :show, status: :ok, location: @panneau }
      else
        format.html { render :edit }
        format.json { render json: @panneau.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /panneaus/1
  # DELETE /panneaus/1.json
  def destroy
    @panneau.destroy
    respond_to do |format|
      format.html { redirect_to panneaus_url, notice: 'Panneau was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_nearest_pannel
    lat = params[:lat]
    long = params[:long]

    if lat && long && @panneaus
      panneaux_sorted = @panneaus.sort_by{|panneau| 
        getDistanceFromLatLonInKm(panneau[:long].to_f,panneau[:lat].to_f,lat.to_f,long.to_f)
      }

      render json: panneaux_sorted.to_json
    else
      render json: {:result=>200}.to_json
    end
  end

  def getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) 

      p = 0.017453292519943295 #Math.PI / 180
      a = 0.5 - Math::cos((lat2 - lat1) * p)/2 + Math::cos(lat1 * p) * Math::cos(lat2 * p) * (1 - Math::cos((lon2 - lon1) * p))/2;
      dist = 12742 * Math.asin(Math.sqrt(a))
      return dist # 2 * R; R = 6371 km

    end

  def deg2rad(deg)
    return deg * (Math::PI/180)
  end
  
private
  # Use callbacks to share common setup or constraints between actions.
  def set_panneau
    @panneau = Panneau.find(params[:id])
  end

  def set_panneaus
    puts "----set panneau --#{params[:ville]}--"
    @panneaus = Panneau.all
    @panneaus = @panneaus.ville(params[:ville]) if params[:ville]

    puts @panneaus.length
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def panneau_params
    params.require(:panneau).permit(:lat, :long, :name, :is_ok, :ville)
  end
end
