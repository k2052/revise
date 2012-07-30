Padrino.configure_apps do
  enable :sessions
  set :session_secret, 'a03d19c8fb39cb325b104905e8496e8ba3e7e194e8839574475478ae4b067bb3'
end

# Mounts the core application for this project
Padrino.mount("ReviseDemoApp").to('/')