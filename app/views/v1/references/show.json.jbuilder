json.status :success

json.links do
  json.references references_url_template
end

json.references do
  json.partial! 'v1/references/reference', reference: @reference
end