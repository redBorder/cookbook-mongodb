# Cookbook Name:: mongodb
#
# Provider:: config
#

action :add do
  begin

    # install package
    yum_package "mongodb-org" do
      action :install
      flush_cache [ :before ]
    end

    service "mongod" do
      service_name "mongod"
      ignore_failure true
      supports :status => true, :restart => true, :enable => true
      action [:start, :enable]
    end

    template "/etc/mongod.conf" do
      source "mongod.conf.erb"
      owner "root"
      owner "root"
      mode 0644
      retries 2
      cookbook "mongodb"
      notifies :restart, "service[mongod]", :delayed
    end

      Chef::Log.info("mongodb has been configured correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    service "mongod" do
      ignore_failure true
      supports :status => true, :enable => true
      action [:stop, :disable]
    end

    # uninstall package
    yum_package "mongodb-org" do
     action :remove
    end
    #
    Chef::Log.info("mongodb has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


action :register do #Usually used to register in consul
  begin
    if !node["mongodb"]["registered"]
      query = {}
      query["ID"] = "mongodb-#{node["hostname"]}"
      query["Name"] = "mongodb"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 27017
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["mongodb"]["registered"] = true
    end
    Chef::Log.info("mongodb service has been registered in consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do #Usually used to deregister from consul
  begin
    if node["mongodb"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/mongodb-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["mongodb"]["registered"] = false
    end
    Chef::Log.info("mongodb service has been deregistered from consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end
