
ActionController::Routing::Routes.draw do |map|
  IdPattern    = /[0-9]+/
  TokenPattern = /[0-9a-f]+/

  map.root :controller => "home", :action => "index"

  map.with_options :controller => "devices" do |devices|
    devices.connect "devices/:action",           :action => /(new|create)/
    devices.device  "device/:device_id",         :action => "show", :device_id => IdPattern
    devices.connect "device/:device_id/:action", :action => /(edit|update|delete|destroy)/, :device_id => IdPattern
  end

  map.with_options :controller => "triggers", :device_id => IdPattern do |triggers|
    triggers.connect "device/:device_id/triggers/:action",            :action => /(new|create)/
    triggers.connect "device/:device_id/trigger/:trigger_id/:action", :action => /(edit|update|delete|destroy)/, :trigger_id => IdPattern
  end

  map.with_options :controller => "email_actions", :device_id => IdPattern, :trigger_id => IdPattern do |email_acts|
    email_acts.connect "device/:device_id/trigger/:trigger_id/acts/email/:action",                 :action => /(new|create)/
    email_acts.connect "device/:device_id/trigger/:trigger_id/act/email/:email_action_id/:action", :action => /(edit|update|delete|destroy)/, :email_action_id => IdPattern
  end

  map.with_options :controller => "http_actions", :device_id => IdPattern, :trigger_id => IdPattern do |http_acts|
    http_acts.connect "device/:device_id/trigger/:trigger_id/acts/http/:action",                :action => /(new|create)/
    http_acts.connect "device/:device_id/trigger/:trigger_id/act/http/:http_action_id/:action", :action => /(edit|update|delete|destroy)/, :http_action_id => IdPattern
  end

  map.with_options :controller => "credentials/email" do |email_credentials|
    email_credentials.connect "credential/emails/:action",                        :action => /(new|create)/
    email_credentials.connect "credential/email/:email_credential_id/:action",    :action => /(created|edit_password|update_password|delete|destroy)/, :email_credential_id => IdPattern
    email_credentials.connect "credential/email/token/:activation_token/:action", :action => /(activation|activate|activated)/, :activation_token => TokenPattern
  end

  map.with_options :controller => "credentials/open_id" do |open_id_credentials|
    open_id_credentials.connect "credentials/open_id/:action",                       :action => /(new|create)/
    open_id_credentials.connect "credential/open_id/:open_id_credential_id/:action", :action => /(delete|destroy)/, :open_id_credential_id => IdPattern
  end

  map.connect "email/:email_address_id/:action",       :controller => "emails", :action => /(created|delete|destroy)/, :email_address_id => IdPattern
  map.connect "email/token/:activation_token/:action", :controller => "emails", :action => /(activation|activate|activated)/, :activation_token => TokenPattern

  map.connect "device/token/:device_token/:action.rdf", :controller => "device_feeds", :device_token => TokenPattern
  map.connect "device/token/:device_token/energies/update/:level",       :controller => "device_api", :action => "update_energy", :device_token => TokenPattern, :level => /\d+/
  map.connect "device/token/:device_token/energies/update/:level/:time", :controller => "device_api", :action => "update_energy", :device_token => TokenPattern, :level => /\d+/, :time => /\d+/

  map.connect "user/token/:user_token/:action.rdf", :controller => "user_feeds", :user_token => TokenPattern

  map.namespace :signup do |signup|
    signup.connect "email/activation/:activation_token", :controller => "email", :action => "activation", :activation_token => /[0-9a-f]+/
  end

  map.connect ":controller/:action/:id"
  map.connect ":controller/:action/:id.:format"
end
