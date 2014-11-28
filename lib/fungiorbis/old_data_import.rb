require 'csv'

module Fungiorbis
  module OldDataImport

    def self.import_users
      User.transaction do
        File.foreach('db/old_data/users.csv') do |line|
          u = User.new
          u.email, u.first_name, u.last_name, u.role, u.institution, u.title, u.password = line.split(',')[0..6].each { |item| item.strip! }
          u.password_confirmation = u.password
          u.confirmed_at = DateTime.now

          u.save!
        end
      end

      puts 'Users import complete'
    end

    def self.import_references
      Reference.transaction do
        File.foreach('db/old_data/references.csv') do |line|
          ref = line.split('#').each { |item| item.strip! }
          r = Reference.new
          r.title = ref[0]
          r.isbn = ref[1] unless ref[1].blank?
          r.url = ref[2] unless ref[2].blank?
          r.save!
        end
      end

      puts 'References import complete'
    end

    def self.import_locations
      Location.transaction do
        File.foreach('db/old_data/locations.csv') do |line|
          loc = line.split(',').each { |item| item.strip! }
          l = Location.new
          l.name = loc[0]
          l.utm = loc[1]
          l.save!
        end
      end

      puts 'Locations import complete'
    end

    def self.import_species
      incomplete_species = []
      existing_species = []
      added_species = []
      Species.transaction do
        File.foreach('db/old_data/species.csv') do |line|
          species = line.split(/,|\//)[0..7].each_with_index do |item, index|
            item.strip!
            index == 1 ? item.downcase! : item.capitalize!
          end

          if species.any? { |field| field.empty? }
            incomplete_species << species
          elsif Species.where(name: species[1], genus: species[0]).first
            existing_species << species
          else
            s = Species.new
            s.genus, s.name, s.familia, s.ordo, s.subclassis, s.classis, s.subphylum, s.phylum = species

            s.save!
            added_species << species
          end
        end
      end

      puts "Species import complete \n#{added_species.length} species imported\n#{existing_species.length} species already present in the database\n#{incomplete_species.length} species not added due to incomplete data"

      write_to_csv_file incomplete_species, 'db/old_data/not_added_species.csv'
      write_to_csv_file existing_species, 'db/old_data/existing_species.csv'
    end

    def self.import_specimens
      invalid_species = []
      invalid_date = []
      invalid_location = []

      added_specimens = []
      Specimen.transaction do
        File.foreach('db/old_data/specimens.csv') do |line|
          specimen = line.split('#').each { |item| item.strip! }

          genus, species_name = specimen[0].split(' / ')

          species = Species.where(name: species_name, genus: genus).first

          unless species
            invalid_species << specimen
            next
          end

          if specimen[2].empty?
            invalid_date << specimen
            next
          else
            # 27.05.1996. - > [27, 5, 1996]
            d = specimen[2].gsub(',', '.').split('.')[0..2].map { |d| d.to_i }
            date = Date.new(d[2], d[1], d[0])
          end

          location = Location.find_by_name(specimen[3])
          unless location
            invalid_location << specimen
            next
          end

          legator = user_from_full_name specimen[4]
          determinator = user_from_full_name specimen[5]

          habitat = parse_habitat specimen[6]
          substrate = parse_substrate specimen[7]

          quantity = specimen[9]

          note = specimen[12]
          unless specimen[11].empty?
            note = note || ''
            note << '\n' unless note.empty?
            note << "Zaštićenost: #{specimen[11]}"
          end

          update_growth_type(species, specimen[9])
          update_nutritive_group(species, specimen[8])
          update_synonyms(species, specimen[0], specimen[1])

          s = Specimen.new
          s.species = species
          s.location = location
          s.legator = legator
          s.legator_text = specimen[4]
          s.determinator = determinator
          s.determinator_text = specimen[5]
          s.date = date
          s.habitats = habitat
          s.substrates = substrate
          s.quantity = quantity
          s.note = note

          s.save!
          added_specimens << specimen

        end
      end

      puts "Specimens import complete \n#{added_specimens.length} specimens imported\n#{invalid_species.length + invalid_location.length + invalid_date.length} specimens not added due to incomplete or incorrect data"

      write_to_csv_file invalid_date, 'db/old_data/not_added_specimens_date.csv'
      write_to_csv_file invalid_species, 'db/old_data/not_added_specimens_species.csv'
      write_to_csv_file invalid_location, 'db/old_data/not_added_specimens_location.csv'
    end

    private

    def self.update_growth_type(species, growth_type)
      types = {
          'pojedinačno' => 'single',
          'grupno' => 'group',
          'busenasto' => 'cluster',
          'resupinantno' => 'resupinate'
      }

      unless species.growth_type == types[growth_type]
        species.growth_type = types[growth_type]
        species.save!
      end
    end

    def self.update_nutritive_group(species, nutritive_group)
      groups = {
          'mikorizna' => 'mycorrhizal',
          'parazit' => 'parasitic',
          'parazit (saprob)' => 'parasitic-saprotrophic',
          'saprob' => 'saprotrophic',
          'saprob (parazit)' => 'saprotrophic-parasitic'
      }

      if !groups[nutritive_group].blank? && species.nutritive_group != groups[nutritive_group]
        species.nutritive_group = groups[nutritive_group]
        species.save!
      end
    end

    def self.parse_substrate(substrate)
      substrates = {
          'lignikolna / mrtav koren' => 'buried_wood',
          'lignikolna / mrtav panj' => 'stump',
          'lignikolna / mrtva grana' => 'branches',
          'lignikolna / mrtvo deblo' => 'lying_trunk',
          'lignikolna / otpaci' => 'litter',
          'lignikolna / živ panj' => 'stump',
          'lignikolna / živa grana' => 'living_tree',
          'lignikolna / živo drvo' => 'living_tree',
          'specifičan' => 'specific',
          'specifičan / gljiva' => 'fungi',
          'specifičan / kupula' => 'acorn',
          'specifičan / šišarka' => 'pinecones',
          'terikolna / stelja' => 'litter',
          'terikolna / zemlja' => 'ground'
      }
      substrates[substrate]
    end

    def self.parse_habitat(habitat)
      habitats = {
          'livada' => 'meadow',
          'antropogeno izmenjeno (voćnjak, park, pored puta)' => 'anthropogenic',
          'put' => 'anthropogenic',
          'šuma / četinarska' => 'forest / coniferous',
          'šuma / četinarska / bor' => 'forest / coniferous / pinus',
          'šuma / četinarska / smrča' => 'forest / coniferous / picea',
          'šuma / četinarska / sađeni bor' => 'forest / coniferous / pinus',
          'šuma / listopadna' => 'forest / decidous',
          'šuma / listopadna / breza' => 'forest / decidous / betula',
          'šuma / listopadna / bukva' => 'forest / decidous / fagus',
          'šuma / listopadna / grab' => 'forest / decidous / carpinus',
          'šuma / listopadna / hrast' => 'forest / decidous / quercus',
          'šuma / listopadna / topola' => 'forest / decidous / populus',
          'šuma / listopadna / vrba' => 'forest / decidous / salix',
          'šuma / listopadna / breza/grab' => 'forest / decidous / betula, carpinus',
          'šuma / listopadna / breza/topola' => 'forest / decidous / betula, populus',
          'šuma / listopadna / breza/grab/bukva/topola' => 'forest / decidous / betula, carpinus, fagus, populus',
          'šuma / listopadna / bukva/grab' => 'forest / decidous / fagus, carpinus',
          'šuma / listopadna / bukva/lipa' => 'forest / decideous / fagus, tilia',
          'šuma / listopadna / bukva/lipa/hrast/grab' => 'forest / decideous / fagus, tilia, quercus, carpinus',
          'šuma / listopadna / hrast/grab' => 'forest / decidous / quercus, carpinus',
          'šuma / listopadna / hrast/bukva' => 'forest / decidous / quercus, fagus',
          'šuma / listopadna / hrast/grab/bukva' => 'forest / decidous / quercus, carpinus, fagus',
          'šuma / listopadna / hrast/grab/lipa' => 'forest / decidous / quercus, carpinus, tilia',
          'šuma / listopadna / hrast/grab/lipa/bukva' => 'forest / decidous / quercus, carpinus, tilia, fagus',
          'šuma / listopadna / hrast/lipa' => 'forest / decidous / quercus, tilia',
          'šuma / listopadna / hrast/lipa/grab/dren' => 'forest / decidous / quercus, tilia, carpinus, cornus',
          'šuma / listopadna / vrba/topola' => 'forest / decidous / salix, populus',
          'šuma / mešovita' => 'forest / mixed',
          'šuma / mešovita / bukva/hrast/sađena jela' => 'forest / mixed / fagus, querqus, abies',
          'šuma / mešovita / lipa/sađeni bor' => 'forest / mixed / tilia, pinus',
          'šuma / mešovita / bukva /smrča' => 'forest / mixed / fagus, picea',
          'travnjak' => 'meadow'
      }

      a = habitats[habitat].split(' / ')

      if !a[1].blank? || !a[2].blank?
        { a[0] => { subhabitat: a[1], species: a[2].to_s.split(', ') } }
      else
        a[0]
      end
    end

    def self.user_from_full_name(full_name)
      users = {
          'A.Mihajlovic, M.M.' => 'mihajlovic.a@fungiorbis.edu',
          'A.Sopka, D.Vranješ' => 'sopka.a@fungiorbis.edu',
          'Buzasi T.' => 'buzasi.t@fungiorbis.edu',
          'Ivanc A.' => 'ivanc.a@fungiorbis.edu',
          'Jović D.' => 'jovic.d@fungiorbis.edu',
          'Kadar Irenka' => 'kadar.i@fungiorbis.edu',
          'Klokočar Zlata' => 'klokocar.z@fungiorbis.edu',
          'Krizmanić I.' => 'krizmanic.i@fungiorbis.edu',
          'M.Maksimović, A.M.' => 'maksimovic.m@fungiorbis.edu',
          'Matavulj M., Karaman M.' => 'milan.matavulj@dbe.uns.ac.rs',
          'Milana Rakić' => 'milana.rakic@dbe.uns.ac.rs',
          'Radišić Predrag' => 'predrag.radisic@dbe.uns.ac.rs',
          'Radnović D.&S.' => 'dragan.radnovic@dbe.uns.ac.rs',
          'Radnović Dragan' => 'dragan.radnovic@dbe.uns.ac.rs',
          'Radnović,Matavulj,B.' => 'dragan.radnovic@dbe.uns.ac.rs',
          'Sabadoš K.' => 'sabados.k@fungiorbis.edu',
          'Site T.' => 'site.t@fungiorbis.edu',
          'Tepavčević Andrea' => 'etepavce@gmail.com'
      }

      User.find_by_email(users[full_name] ? users[full_name] : 'maja.karaman@dbe.uns.ac.rs')
    end

    def self.update_synonyms(species, name, synonym)
      unless name == synonym
        synonyms = species.synonyms.to_s.split(',')
        synonyms << synonym.gsub(' / ', ' ')
        species.synonyms = synonyms.join(',')
        species.save!
      end
    end

    def self.write_to_csv_file(array, file_name)
      CSV.open(file_name, 'w+') do |csv|
        array.each do |row|
          csv << row
        end
      end
    end
  end
end