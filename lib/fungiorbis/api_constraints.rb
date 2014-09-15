module Fungiorbis
  class ApiConstraints
    def initialize(options)
      @version = options[:version]
      @default = options[:default]
      @domain = options[:domain]
    end

    # http://vimeo.com/30586709
    def matches?(req)
      @default || req.headers['Accept'].include?("application/vnd.#{@domain}+json; version=#{@version}")
    end
  end
end
