module Pageable
  extend ActiveSupport::Concern

  private

  def set_pagination(search_result, url_template)
    @meta ||= {}
    @meta[:page] = params[:page].blank? ? 1 : params[:page].to_i
    @meta[:per_page] = page_size_within_bounds?(search_result.klass, params) ? params['perPage'].to_i : search_result.klass::PER_PAGE
    @meta[:count] = search_result.count

    @meta[:page] = 1 if page_count_out_of_bounds?

    @meta[:page_count] = calculate_page_count
    @meta[:previous_page] = first_page? ? nil : @meta[:page] - 1
    @meta[:next_page] = last_page? ? nil : @meta[:page] + 1

    @meta[:previous_href] = first_page? ? nil : previous_href(url_template)
    @meta[:next_href] = last_page? ? nil : next_href(url_template)
  end

  def page_size_within_bounds?(model_class, params)
    (1..model_class::MAX_PER_PAGE).include?(params['perPage'].to_i)
  end

  def page_count_out_of_bounds?
    @meta[:page] > 1 && @meta[:count] < (@meta[:page] - 1) * @meta[:per_page]
  end

  def calculate_page_count
    @meta[:count] / @meta[:per_page] + (@meta[:count] % @meta[:per_page] == 0 ? 0 : 1)
  end

  def first_page?
    @meta[:page] == 1
  end

  def last_page?
    @meta[:page] == @meta[:page_count]
  end

  def page_href(page, url_template)
    send(url_template, page: page, perPage: @meta[:per_page])
  end

  def next_href(url_template)
    page_href(@meta[:page]+1, url_template)
  end

  def previous_href(url_template)
    page_href(@meta[:page]-1, url_template)
  end
end