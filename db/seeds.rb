# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'fungiorbis/old_data_import'

User.create(email: 'ela@fungiorbis.edu',
            password: 'Ela12345!',
            password_confirmation: 'Ela12345!',
            first_name: 'Eleonora',
            last_name: 'Bošković',
            role: User::SUPERVISOR_ROLE,
            institution: 'Prirodno-matematički fakultet',
            title: 'MSc',
            confirmed_at: DateTime.now)

Fungiorbis::OldDataImport.import_species