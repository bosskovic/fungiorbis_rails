When(/^I send a POST request to "\/references" with ([\w\s-]*)(?: and ")?(#{CAPTURE_FIELDS})?(?:")?$/) do |situation, fields|
  params_hash = keys_to_camel_case(FactoryGirl.attributes_for(:reference), output: :symbol)

  case situation
    when 'all mandatory fields valid'
      params_hash.merge! random_attributes_hash_for(fields, hash_keys: :symbol) if fields
    when 'all mandatory fields missing'
      keys_for_removal = [:title]
      remove_keys_from_hash!(params_hash, keys_for_removal)
    when 'url not unique'
      reference = FactoryGirl.create(:reference, url: 'http://some_site')
      params_hash[:url] = reference.url
    when 'isbn not unique'
      reference = FactoryGirl.create(:reference, isbn: 'abc')
      params_hash[:isbn] = reference.isbn
    else
      raise "unknown situation: #{situation}"
  end

  params_json = { :references => params_hash }.to_json

  steps %{
    When I send a POST request to "/references" with the following json:
    """
    #{params_json}
    """
  }
end

When(/^I send a PATCH request (?:for|to) "\/references\/:UUID" \(last reference\) with (.*?)$/) do |situation|
  load_last_record(:reference)

  params_hash = keys_to_camel_case(FactoryGirl.attributes_for(:reference), output: :symbol)

  case situation
    when 'url not unique'
      reference = FactoryGirl.create(:reference, url: 'http://site')
      params_hash[:url] = reference.url
    when 'isbn not unique'
      reference = FactoryGirl.create(:reference, isbn: 'abc')
      params_hash[:isbn] = reference.isbn
    when 'all mandatory fields removed'
      [:title].each do |field|
        params_hash[field] = nil
      end
    else
      raise "unknown situation: #{situation}"
  end

  path = "/references/#{last_record.uuid}"
  json = { references: params_hash }.to_json

  steps %{
    When I send a PATCH request to "#{path}" with the following json:
    """
    #{ json }
    """
  }
end