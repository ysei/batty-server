
ActionController::Routing::Routes.draw do |map|
  UserToken   = /[0-9a-f]+/
  DeviceToken = /[0-9a-f]+/
  DeviceId    = /[0-9]+/
  TriggerId   = /[0-9]+/

  map.root :controller => "home", :action => "index"

  map.connect "devices/:action",   :controller => "devices"
  map.device  "device/:device_id", :controller => "devices", :action => "show", :device_id => DeviceId
  map.connect "device/:device_id/triggers/:action",    :controller => "triggers", :device_id => DeviceId
  map.connect "device/:device_id/trigger/:trigger_id", :controller => "triggers", :action => "show", :device_id => DeviceId, :trigger_id => TriggerId
  map.connect "device/:device_id/trigger/:trigger_id/acts/email/:action", :controller => "email_actions", :device_id => DeviceId, :trigger_id => TriggerId
  map.connect "device/:device_id/trigger/:trigger_id/acts/http/:action",  :controller => "http_actions", :device_id => DeviceId, :trigger_id => TriggerId

  map.connect "device/token/:device_token/:action.rdf", :controller => "device_feeds", :device_token => DeviceToken
  map.connect "device/token/:device_token/energies/update/:level",       :controller => "device_api", :action => "update_energy", :device_token => DeviceToken, :level => /\d+/
  map.connect "device/token/:device_token/energies/update/:level/:time", :controller => "device_api", :action => "update_energy", :device_token => DeviceToken, :level => /\d+/, :time => /\d+/

  map.connect "user/token/:user_token/:action.rdf", :controller => "user_feeds", :user_token => UserToken

  map.connect "auth/email/:action",  :controller => "email_auth"
  map.connect "auth/openid/:action", :controller => "open_id_auth"

  map.connect "signup/email/:action",                      :controller => "email_signup"
  map.connect "signup/email/activation/:activation_token", :controller => "email_signup", :action => "activation", :activation_token => /[0-9a-f]+/
  map.connect "signup/openid/:action",                     :controller => "open_id_signup"

  map.connect ":controller/:action/:id"
  map.connect ":controller/:action/:id.:format"
end
