# Cookbook:: mongodb
# Provider:: config

action :add do
  begin
    # install package
    dnf_package 'mongodb-org' do
      action :install
      flush_cache [ :before ]
    end

    service 'mongod' do
      service_name 'mongod'
      ignore_failure true
      supports status: true, restart: true, enable: true
      action [:start, :enable]
    end

    template '/etc/mongod.conf' do
      source 'mongod.conf.erb'
      owner 'root'
      owner 'root'
      mode '0644'
      retries 2
      cookbook 'mongodb'
      notifies :restart, 'service[mongod]', :delayed
    end

    node.normal['redborder']['services']['mongodb'] = true
    node.normal['redborder']['services']['overwrite']['mongodb'] = true

    Chef::Log.info('mongodb has been configured correctly.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'mongod' do
      ignore_failure true
      supports status: true, enable: true
      action [:stop, :disable]
    end

    # uninstall package
    dnf_package 'mongodb-org' do
      action :remove
    end

    node.normal['redborder']['services']['mongodb'] = false
    node.normal['redborder']['services']['overwrite']['mongodb'] = false

    Chef::Log.info('mongodb has been deleted correctly.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['mongodb']['registered']
      query = {}
      query['ID'] = "mongodb-#{node['hostname']}"
      query['Name'] = 'mongodb'
      query['Address'] = "#{node['ipaddress_sync']}"
      query['Port'] = 27017
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['mongodb']['registered'] = true
    end
    Chef::Log.info('mongodb service has been registered in consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['mongodb']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/mongodb-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['mongodb']['registered'] = false
    end
    Chef::Log.info('mongodb service has been deregistered from consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end
