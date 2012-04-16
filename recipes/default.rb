#
# Cookbook Name:: gitolite
# Recipe:: default
#
# Copyright 2012, cj Advertising, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

execute "preseed gitolite" do
  command "debconf-set-selections /var/cache/local/preseeding/gitolite.seed"
  action :nothing
end

template "/var/cache/local/preseeding/gitolite.seed" do
  source "gitolite.seed.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user => node["gitolite"]["user"],
    :key => node["gitolite"]["key"],
    :path => node["gitolite"]["path"]
  )
  notifies :run, resources(:execute => "preseed gitolite"), :immediately
end

package "gitolite"

# Set up sudoers
node["gitolite"]["sudoers"].each do |u|
  
  # Allow user to run as gitolite
  sudo "gitolite-#{u}" do
    user u
    runas node["gitolite"]["user"]
    commands ["ALL"]
    nopasswd true
  end

  # Allow gitolite to run as user
  sudo "gitolite-#{u}-reverse" do
    user node["gitolite"]["user"]
    runas u
    commands ["ALL"]
    nopasswd true
  end
end