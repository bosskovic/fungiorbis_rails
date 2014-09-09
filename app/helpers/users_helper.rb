module UsersHelper

  def users_url_template
    users_url
  end

  def user_url_template
    user_url(uuid: 'xxx').gsub('xxx', '{users.id}')
  end
end