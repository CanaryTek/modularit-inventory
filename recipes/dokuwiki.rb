#
# Cookbook Name:: dokuwiki
# Recipe:: default
#
# Copyright 2013, CanaryTek
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Get admindomains
admindomains=search(:role, "admindomain:*").sort!{|x, y| x.name <=> y.name}

admindomains.each do |admindomain|
  Chef::Log.info("Generating nodes info for: #{admindomain.name}")
  nodes = search(:node, "admindomain:#{admindomain.name}").sort!{|x, y| x.name <=> y.name}
  directory "#{node['modularit-inventory']['dokuwiki']['data_dir']}/#{admindomain.name}" do
    owner node['modularit-inventory']['dokuwiki']['owner']
    group node['modularit-inventory']['dokuwiki']['group']
  end
  # List of nodes
  template "#{node['modularit-inventory']['dokuwiki']['data_dir']}/#{admindomain.name}/nodes.txt" do
    source 'nodes.dokuwiki.erb'
    owner node['modularit-inventory']['dokuwiki']['owner']
    group node['modularit-inventory']['dokuwiki']['group']
    mode 00640
    variables(:admindomain => admindomain.name,
              :nodes => nodes)
  end
  # Create node entries
  nodes.each do |n|
    template "#{node['modularit-inventory']['dokuwiki']['data_dir']}/#{admindomain.name}/#{n.name}_chef.txt" do
      source 'single_node.dokuwiki.erb'
      owner node['modularit-inventory']['dokuwiki']['owner']
      group node['modularit-inventory']['dokuwiki']['group']
      mode 00640
      variables(:n => n)
    end
  end
 
end

## Reports
directory "#{node['modularit-inventory']['dokuwiki']['data_dir']}/rasca_reports" do
  owner node['modularit-inventory']['dokuwiki']['owner']
  group node['modularit-inventory']['dokuwiki']['group']
end
# Backups
template "#{node['modularit-inventory']['dokuwiki']['data_dir']}/rasca_reports/backup.txt" do
  source 'report_backup.dokuwiki.erb'
  owner node['modularit-inventory']['dokuwiki']['owner']
  group node['modularit-inventory']['dokuwiki']['group']
  mode 00640
  variables(:nodes => search(:node, "*:*").sort!{|x, y| x.name <=> y.name})
end
