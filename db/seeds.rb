# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

  # load json from file
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

  actualFolder = File.dirname(__FILE__)
  geo_json_path = File.join(actualFolder,"carte__mavoixlyon.geojson")
  geo_jsons = getHashFromJsonFile geo_json_path

  geo_json_features = geo_jsons[:features]

  panneaux_mavoix = geo_json_features.map{|geojson| 
    if geojson[:geometry]
      if geojson[:geometry][:coordinates]
        if geojson[:properties]
          if geojson[:properties][:description]
            {:lat => geojson[:geometry][:coordinates][0], :long =>geojson[:geometry][:coordinates][1], :name => geojson[:properties][:description], :is_ok=> true}
          end
        end
      end
    end
  }

	panneaux_mavoix = panneaux_mavoix.select{|pnx| pnx != nil}

	panneaux_mavoix.each{|panneau|
		Panneau.create(panneau)
	}  