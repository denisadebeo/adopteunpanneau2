# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'
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


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Charge les fichiers des geojsons qui sont les circo manquante du csv
#   villes_a_faire = [
#    "13, Bouches-du-rhônes _ 04 CIRCO",
#  ]
#    "69, Rhône, Rhône-Alpes _ 03 CIRCO", # done in geojson
#    "13, Bouches-du-rhônes _ 14 CIRCO", # done in geojson
#    "67, Bas-Rhin, Alsace _ 01 CIRCO", # done in geo json
#    "93 - seine saint - denis __ 07 CIRCO"# done in geojson
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  extension = "geojson"
  actualFolder = File.dirname(__FILE__)
  all_geojson_filter = "#{actualFolder}/circo/**/*.#{extension}"
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




# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Charge le fichier CSV seulement pour certain circo
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#    "69, Rhône, Rhône-Alpes _ 03 CIRCO", # done in geojson
#    "13, Bouches-du-rhônes _ 14 CIRCO", # done in geojson
#    "67, Bas-Rhin, Alsace _ 01 CIRCO", # done in geo json
#    "93 - seine saint - denis __ 07 CIRCO"# done in geojson

  villes_a_conserver = [
    "17, Charente-Maritime, Poitou-Charentes _ 01 CIRCO",
    "17, Charente-Maritime, Poitou-Charentes _ 02 CIRCO",
    "30, Gard, Languedoc-Roussillon _ 02 CIRCO",
    "31, Haute-Garonne, Midi-Pyrénées _ 04 CIRCO",
    "33, Gironde, Aquitaine _ 03 CIRCO",
    "34, Hérault, Languedoc-Roussillon _ 02 CIRCO",
    "34, Hérault, Languedoc-Roussillon _ 05 CIRCO",
    "34, Hérault, Languedoc-Roussillon _ 06 CIRCO",
    "35, Ille-et-Vilaine, Bretagne _ 08 CIRCO",
    "38, Isère, Rhône-Alpes _ 01 CIRCO",
    "44, Loire-Atlantique, Pays de la Loire _ 02 CIRCO",
    "59, Nord, Nord-Pas-de-Calais _ 01 CIRCO",
    "72, Sarthe, Pays de la Loire _ 01 CIRCO",
    "74, Haute-Savoie, Rhône-Alpes _ 01 CIRCO",
    "75, Paris, Île-de-France _ 01 CIRCO",
    "75, Paris, Île-de-France _ 02 CIRCO",
    "75, Paris, Île-de-France _ 05 CIRCO",
    "75, Paris, Île-de-France _ 06 CIRCO",
    "75, Paris, Île-de-France _ 10 CIRCO",
    "75, Paris, Île-de-France _ 15 CIRCO",
    "75, Paris, Île-de-France _ 17 CIRCO",
    "75, Paris, Île-de-France _ 18 CIRCO",
    "83, Var, Provence-Alpes-Côte d'Azur _ 01 CIRCO",
    "85, Vendée, Pays de la Loire _ 01 CIRCO",
    "86, Vienne, Poitou-Charentes _ 02 CIRCO",
    "92, Hauts-de-Seine, Ile de France _ 02 CIRCO",
    "95, Val-d'Oise, Île-de-France _ 04 CIRCO"
  ]

  # Hérault 6ème circonscription MANQUE
  # 92-2

  actualFolder = File.dirname(__FILE__)
  all_geojson_filter = "#{actualFolder}/circo/panneaux-election-_from mavoix_with_for_adopte_un_panneau.csv"
  CSV.foreach(all_geojson_filter, encoding: "bom|utf-8",headers: :first_row, col_sep: ';') do |data_line_from_csv|
    if data_line_from_csv.all? {|x| x != ""}
      if data_line_from_csv.all? {|x| x != nil}
        if !data_line_from_csv[0].nil? #&& !data_line_from_csv[1].nil? && !data_line_from_csv[2].nil? && !data_line_from_csv[3].nil?
          nom = data_line_from_csv[3]
          nom = "Aucun nom renseigner" if !data_line_from_csv[3]

          if villes_a_conserver.include? data_line_from_csv[0]
            json = {:ville=> data_line_from_csv[0].gsub(", ","-").gsub(" _ ","-").gsub(" ","-"), :long =>  data_line_from_csv[1].to_f, :lat => data_line_from_csv[2].to_f, :name => nom, :is_ok=> false}
            panneaux_mavoix.push json
          end
        end
      end
    end
  end

  panneaux_mavoix = panneaux_mavoix.select{|pnx| pnx != nil}
  panneaux_mavoix.uniq!
  panneaux_mavoix.each{|panneau|
    #existing_panneau = Panneau.where(:ville => panneau[:ville]).where(:name => panneau[:name]).where(:long => panneau[:long])
    #puts existing_panneau
    #puts "-"
    #if existing_panneau == []
      Panneau.create(panneau)
    #else 
    #  puts "non #{existing_panneau.to_json}"
    #end
  } 

}
