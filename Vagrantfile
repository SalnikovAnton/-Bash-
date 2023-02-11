# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "centos/stream8",
        :ip_addr => '192.168.56.10',
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|
  config.vm.synced_folder "./", "/vagrant"
      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "512"]
          end
          
          box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
            yum install epel-release -y
            yum install nginx -y
            systemctl start nginx
            systemctl enable nginx
            cp /vagrant/nginx/nginx.conf /etc/nginx/nginx.conf
            cp /vagrant/nginx/default.conf /etc/nginx/conf.d/default.conf
            cp /vagrant/index.html /usr/share/nginx/html
            systemctl restart nginx
            yum -y install mailx
            yum install cronie -y
            service crond start
          SHELL
      end
  end
end	
