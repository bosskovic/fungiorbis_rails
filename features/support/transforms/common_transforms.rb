CAPTURE_RECOGNIZED_STATUS = Transform /^OK|UNPROCESSABLE|FORBIDDEN|UNAUTHORIZED|CREATED$/ do |status|
  status
end