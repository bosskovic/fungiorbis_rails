module CommonHelper

  def last_href
    if @last_href.nil?
      raise '@last_href was not set'
    else
      @last_href
    end
  end

end

World(CommonHelper)