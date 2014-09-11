module MetaHelper

def pagination_with_context(context, model_class)
    count = model_count model_class

    case context
      when 'without meta params'
        page = 1
        per_page = model_class.per_page
      when 'with perPage within limit'
        page = 2
        per_page = model_class.per_page - 1
      when 'with perPage outside the limit'
        page = 3
        per_page = model_class.per_page
      when 'with page outside the limit'
        page = 1
        per_page = model_class.per_page
      else
        raise 'unknown context'
    end

    pg_count = page_count(model_class, per_page)
    pagination(model_class, page, per_page, pg_count, count)
  end


  private

  def pagination(model, page, per_page, page_count, count)
    page ||= 1

    per_page ||= model.per_page
    page_count ||= 1
    previous_page = page == 1 ? nil : page-1
    next_page = page == page_count ? nil : page+1
    previous_href = previous_page ? "http://test.host/#{model.to_s.downcase.pluralize}?page=#{previous_page}&perPage=#{per_page}" : nil
    next_href = next_page ? "http://test.host/#{model.to_s.downcase.pluralize}?page=#{next_page}&perPage=#{per_page}" : nil
    { 'page' => page,
      'perPage' => per_page,
      'count' => count,
      'include' => [],
      'pageCount' => page_count,
      'previousPage' => previous_page,
      'nextPage' => next_page,
      'previousHref' => previous_href,
      'nextHref' => next_href }
  end

  def page_count(model, per_page)
    count = model_count(model)
    count / per_page + (count % per_page ? 1 : 0)
  end

  def model_count(model)
    @model_count ||= model.respond_to?(:active) ? model.active.count : model.count
  end
end
