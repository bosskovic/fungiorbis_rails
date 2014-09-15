json.id reference.uuid

reference_fields = to_underscore V1::ReferencesController::PUBLIC_FIELDS
json.extract! reference, *reference_fields