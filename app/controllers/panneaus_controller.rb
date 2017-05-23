class PanneausController < ApplicationController
  before_action :set_panneau, only: [:show, :edit,:edit_state, :update, :destroy]
  before_action :set_panneaus, only: [:index, :get_nearest_pannel, :open_street_map, :google_map]
  
  # GET /panneaus
  # GET /panneaus.json
  def index
    lat = params[:lat]
    long = params[:long]
    is_ok = params[:is_ok]
    id_panneaux = params[:id_panneaux] 
    if params[:editable]
      @editable = true
    end
  end

  def open_street_map
    lat = params[:lat]
    long = params[:long]
    is_ok = params[:is_ok]
    id_panneaux = params[:id_panneaux] 
  end

  def google_map
    lat = params[:lat]
    long = params[:long]
    is_ok = params[:is_ok]
    id_panneaux = params[:id_panneaux] 
  end

  # GET /panneaus/1
  # GET /panneaus/1.json
  def show
  end

  # GET /panneaus/new
  def new
    @villes = Panneau.select(:ville).map(&:ville).uniq
    @panneau = Panneau.new
    if params[:ville]
      @panneau.ville = params[:ville]
    end
  end

  # GET /panneaus/1/edit
  def edit
    @villes = Panneau.select(:ville).map(&:ville).uniq
  end

  def edit_state
  end

  # POST /panneaus
  # POST /panneaus.json
  def create
    @panneau = Panneau.new(panneau_params)

    respond_to do |format|
      if @panneau.save
        format.html { redirect_to "/panneaus?editable=true&ville=#{@panneau.ville}", notice: 'Panneau was successfully created.' }
        format.json { render :show, status: :created, location: @panneau }
      else
        format.html { render :new }
        format.json { render json: @panneau.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /panneaus/1.json
  def update

    respond_to do |format|
      if @panneau.update(panneau_params)

        format.html { redirect_to "/panneaus?editable=true&ville=#{@panneau.ville}" , notice: 'Panneau was successfully updated.' }
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
    ville = @panneau.ville.to_s
    @panneau.destroy
    respond_to do |format|
      format.html { redirect_to panneaus_url(:ville=>ville,:editable=>true), notice: 'Panneau was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_nearest_pannel

    lat = params[:lat]
    long = params[:long]
    is_ok = params[:is_ok]
    id_panneaux = params[:id_panneaux]

    if id_panneaux && is_ok

      @panneau = @panneaus.find(id_panneaux.to_i)
      if is_ok != "false" && is_ok != false

        @panneau.update(:is_ok=> true)
      else

        @panneau.update(:is_ok=> false)
      end
    end

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
  
  def secret_geo_json_loading
    #patch for adding marseille 4 ieme circo
    extension = "geojson"
    actualFolder = File.dirname(__FILE__)
    all_geojson_filter = "#{actualFolder}/../../db/circo/*.#{extension}"
    all_json_files = Dir.glob(all_geojson_filter)

    all_json_files.each{|geo_json_path|

      geo_jsons = getHashFromJsonFile geo_json_path

      ville = File.basename(geo_json_path, ".#{extension}")

      geo_json_features = geo_jsons[:features]

      panneaux_mavoix = geo_json_features.map{|geojson| 
        if geojson[:geometry]
          if geojson[:geometry][:coordinates]
            if geojson[:properties]
              if geojson[:properties][:description]
                {:lat => geojson[:geometry][:coordinates][0], :long =>geojson[:geometry][:coordinates][1], :name => geojson[:properties][:description], :is_ok=> false, :ville=>ville}
              elsif geojson[:properties][:Description]
                {:lat => geojson[:geometry][:coordinates][0], :long =>geojson[:geometry][:coordinates][1], :name => geojson[:properties][:Description], :is_ok=> false, :ville=>ville}
              elsif geojson[:properties][:Nom]
                {:lat => geojson[:geometry][:coordinates][0], :long =>geojson[:geometry][:coordinates][1], :name => geojson[:properties][:Nom], :is_ok=> false, :ville=>ville}
              elsif geojson[:properties][:Name]
                {:lat => geojson[:geometry][:coordinates][0], :long =>geojson[:geometry][:coordinates][1], :name => geojson[:properties][:Name], :is_ok=> false, :ville=>ville}
              else
                {:lat => geojson[:geometry][:coordinates][0], :long =>geojson[:geometry][:coordinates][1], :name => "voir sur la carte", :is_ok=> false, :ville=>ville}
              end
            else
              puts "no geojson[:properties]"
            end
          else
            puts "no geojson[:geometry][:coordinates] "
          end
        else
          puts "no geojson[:geometry]"
        end
      }
      puts panneaux_mavoix.inspect
      panneaux_mavoix = panneaux_mavoix.select{|pnx| pnx != nil}
      panneaux_mavoix.uniq!
      panneaux_mavoix.each{|panneau|
        existing_panneau = Panneau.where(:ville => panneau[:ville]).where(:name => panneau[:name]).where(:long => panneau[:long])

        if existing_panneau == []
          Panneau.create(panneau)
        else 
          puts "non #{existing_panneau.to_json}"
        end
      }
    } 
    redirect_to panneaus_url, notice: 'Panneau ajouté.'
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_panneau
    @panneau = Panneau.find(params[:id])
  end

  def set_panneaus
    #puts "----set panneau --#{params[:ville]}--"
    @panneaus = Panneau.all
    if params[:ville]
      if params[:ville] == "Paris"
        @panneaus = @panneaus.where("ville like ?", "%Paris%")
      else
        @panneaus = @panneaus.ville(params[:ville]) if params[:ville]
      end
    end
    @panneaus = @panneaus.order(:name)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def panneau_params
    params.require(:panneau).permit(:lat, :long, :name, :is_ok, :ville)
  end

  def getHashFromJsonFile(jsonFilePath, sym = true)
      # get the hash define in the jsonFilePath.json file
    # configuration are define by symbol (ex: configurations[:key]) except if sym is false

    if !File.exist?(jsonFilePath)
        puts "no file : #{jsonFilePath}"
        return nil
      end
      jsonConfigurationFile = File.read(jsonFilePath)
      
      begin
        hash = JSON.parse(jsonConfigurationFile,:symbolize_names => sym)
      rescue JSON::ParserError
          return nil
      end
      return hash
  end  
end
