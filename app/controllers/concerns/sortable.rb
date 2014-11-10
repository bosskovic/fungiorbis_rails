module Sortable
  extend ActiveSupport::Concern

  private

  def sort_and_order(fields)
    if params['sort']
      if params['sort'][0] == '-'
        params['sort'][0] = ''
        order = :desc
      else
        order = :asc
      end
      if fields.include?(params['sort'].to_sym)
        sort = params[:sort].to_sym
      else
        sort = fields.first
      end
      { sort => order }
    else
      { fields.first => :asc }
    end
  end
end