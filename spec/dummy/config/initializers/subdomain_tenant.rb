class SubdomainTenant
  def initialize(app, environment = Rails.env)
    @app = app
    @environment = environment
  end

  def call(env)
    request = Rack::Request.new(env)
    tenant = nil

    unless ip_host?(request.host)
      subdomain = request.host.split(".").first.presence
      tenant = Tenant.find_by(identifier: subdomain) if subdomain.present?
    end

    if tenant
      RLS.process(tenant.id) { @app.call(env) }
    else
      @app.call(env)
    end
  end

  private

  def ip_host?(host)
    !/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/.match(host).nil?
  end
end

Rails.application.config.middleware.use SubdomainTenant
