module Includable
  extend ActiveSupport::Concern

  private

  def set_inclusions
    action = action_name.to_sym
    @inclusions = params['include'] ? params['include'].split(',') : default_inclusions(action)
  end

  def default_inclusions(action)
    raise 'Includable::default_inclusions has to be overriden'
  end
end