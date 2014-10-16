require 'fungiorbis/old_data_import'

namespace :import do

  desc 'Import species from the csv file'
  task species: :environment do
    Fungiorbis::OldDataImport.import_species
  end


end