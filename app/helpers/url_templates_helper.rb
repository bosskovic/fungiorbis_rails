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
end