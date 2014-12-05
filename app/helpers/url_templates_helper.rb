module UrlTemplatesHelper

  def users_url_template
    users_url
  end

  def user_url_template
    user_url(uuid: 'xxx').gsub('xxx', '{users.id}')
  end

  def species_index_url_template
    species_index_url
  end

  def species_url_template
    species_url(uuid: 'xxx').gsub('xxx', '{species.id}')
  end

  def specimens_url_template
    specimens_url
  end

  def specimen_url_template
    specimens_url(uuid: 'xxx').gsub('xxx', '{specimens.id}')
  end

  def references_url_template
    references_url
  end

  def reference_url_template
    reference_url(uuid: 'xxx').gsub('xxx', '{references.id}')
  end

  def characteristics_url_template
    species_characteristics_url(species_uuid: 'xxx').gsub('xxx', '{species.id}')
  end

  def characteristic_url_template
    species_characteristic_url(species_uuid: 'xxx', uuid: 'yyy').gsub('xxx', '{species.id}').gsub('yyy', '{characteristics.id}')
  end
end