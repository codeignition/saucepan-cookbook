#
# Cookbook Name:: saucepan-cookbook
# Recipe:: default
#
# Copyright (C) 2014 Sinister Light
#
# All rights reserved - Do Not Redistribute
#

groups = data_bag_item('sshadmin','group')
groups.delete("id")

users  = data_bag_item('sshadmin','user')
users.delete("id")

mygroups = []
groups.each do |name, query|
  mygroups.push(name) if search(:node, query).collect(&:name).include?(node.name)
end

myusers = []
users.each do |name, info|
  myusers.push(name) if (info['groups'] & mygroups).length > 0
end

users.select!{|name,info| myusers.include? name }

users.each do |name, info|
  user name do
    uid info["user_id"]
    home "/opt/#{name}"
    not_if "grep #{name} /etc/passwd"
  end

  directory "/opt/#{name}" do
    owner name
    mode 00755
  end

  directory "/opt/#{name}/.ssh" do
    owner name
    mode 00700
  end

  file "/opt/name/.ssh/authorized_keys" do
    owner name
    content info["ssh_key"]
    mode 00700
  end
end
