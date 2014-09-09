module CamelCaseConvertible
  extend ActiveSupport::Concern

  def keys_to_underscore(params)
    r = {}
    params.each_key do |key|
      r[key.underscore] = params[key]
    end
    r
  end

  def keys_to_camel_case(params)
    r = {}
    params.each_key do |key|
      r[key.to_s.camelize(:lower)] = params[key]
    end
    r
  end



  private

  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("-", "_").
        downcase
  end
end