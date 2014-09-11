CAPTURE_SPECIES_FIELDS = Transform /^(?:(?:name|genus|familia|ordo|subclassis|classis|subphylum|phylum|synonyms)(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  fields.gsub('and', ',').split(',').map { |e| e.strip }
end