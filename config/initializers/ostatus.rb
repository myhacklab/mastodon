Rails.application.configure do
  config.x.local_domain = ENV['LOCAL_DOMAIN'] || "localhost:#{ENV['PORT'] || 3000}"
  config.x.hub_url      = ENV['HUB_URL']      || 'https://pubsubhubbub.superfeedr.com'
  config.x.use_https    = ENV['LOCAL_HTTPS'] == 'true'

  config.action_mailer.default_url_options = { host: config.x.local_domain, protocol: config.x.use_https ? 'https://' : 'http://', trailing_slash: false }

  if Rails.env.production?
    config.action_cable.allowed_request_origins = ["http#{config.x.use_https ? 's' : ''}://#{config.x.local_domain}"]
  end
end
