# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'fungiorbis/old_data_import'

[
    { email: 'ela@fungiorbis.edu',
      password: 'Ela12345!',
      password_confirmation: 'Ela12345!',
      first_name: 'Eleonora',
      last_name: 'Bošković',
      role: User::SUPERVISOR_ROLE,
      institution: 'Prirodno-matematički fakultet',
      title: 'MSc',
      confirmed_at: DateTime.now
    },
    {
        email: 'milana@fungiorbis.edu',
        password: 'Ela12345!',
        password_confirmation: 'Ela12345!',
        first_name: 'Milana',
        last_name: 'Rakić',
        role: User::SUPERVISOR_ROLE,
        institution: 'Prirodno-matematički fakultet',
        title: 'MSc',
        confirmed_at: DateTime.now
    },
    {
        email: 'maja@fungiorbis.edu',
        password: 'Ela12345!',
        password_confirmation: 'Ela12345!',
        first_name: 'Maja',
        last_name: 'Karaman',
        role: User::SUPERVISOR_ROLE,
        institution: 'Prirodno-matematički fakultet',
        title: 'PhD',
        confirmed_at: DateTime.now
    },
    {
        email: 'ljiljana@fungiorbis.edu',
        password: 'Ela12345!',
        password_confirmation: 'Ela12345!',
        first_name: 'Ljiljana',
        last_name: 'Janjić',
        role: User::SUPERVISOR_ROLE,
        institution: 'Prirodno-matematički fakultet',
        title: 'MSc',
        confirmed_at: DateTime.now
    },
    {
        email: 'dragisa@fungiorbis.edu',
        password: 'Ela12345!',
        password_confirmation: 'Ela12345!',
        first_name: 'Dragiša',
        last_name: 'Savić',
        role: User::CONTRIBUTOR_ROLE,
        institution: 'NP Fruška gora',
        title: 'BSc',
        confirmed_at: DateTime.now }
].each do |user_attributes|
  User.create user_attributes
end

[
    { title: 'Enciklopedija gljiva', authors: 'Romano Božac', isbn: '978-953-0-61473-4', url: nil },
    { title: 'Gljive Srbije i zapadnog Balkana', authors: 'Branislav Uzelac', isbn: '978-953-0-61473-5', url: nil },
    { title: 'Mushrooms fungi', authors: 'Phillips', isbn: '978-953-0-61473-6', url: nil },
    { title: 'Index Fungorum', authors: 'Anon', isbn: nil, url: 'http://www.indexfungorum.org' }
].each do |reference_attributes|
  Reference.create reference_attributes
end


Fungiorbis::OldDataImport.import_species