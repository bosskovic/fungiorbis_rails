json.status :success

json.links do
  json.references reference_url_template
end

json.references @references, partial: 'v1/references/reference', collection: @references, as: :reference

json.meta do
  json.references do
    json.partial! 'v1/common/meta'
  end
end