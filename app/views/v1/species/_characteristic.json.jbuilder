json.id characteristic.uuid

characteristic_fields = to_underscore(V1::CharacteristicController::PUBLIC_FIELDS)
json.extract! characteristic, *characteristic_fields