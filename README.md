# Provisioning Agency

## Production
yalla working on it, ```ufft!```

## Development
setup your machine for some magic!

### Requirements
- [vagrant](https://docs.vagrantup.com/v2/installation/)
- [ansible 1.5+](http://docs.ansible.com/intro_installation.html)

### Installation

- clone this repository
- download any CentOS 64-bit image from [Vagrant boxes](http://www.vagrantbox.es), minimal preferred,
    with the following command: ```vagrant box add CentOS64 [url]```
- then ```vagrant init CentOS64```

#### From here on we have two options to run the dev environment:

1. **Vagrant**: Will launch 3 interconnected Vagrant instances; load balancing, web server and database server. (recommended)
2. **Docker**: Will have one Vagrant instance running 3 Docker containers replacing the instances from option 1. (broken at the moment)

#### Vagrant
- open ```app-dev.yml``` and make the ```source:``` point to your source code folder
- we're ready to launch: ```vagrant up```
- in the case of any failures while provisioning (just in case), run ```vagrant provision``` and it will heal itself
- after the launch and provisioning is over, you will have access to the servers as follows:
    - ```vagrant ssh web``` for web server with private IP ```192.168.50.10```
    - ```vagrant ssh lb``` for load balancer with private IP ```192.168.50.4```
    - ```vagrant ssh db``` for databases with private IP ```192.168.50.20```

    > you may add any instances you like to the cluster
    > just make sure you don't clash private IPs,
    > you may also follow a convenience in spreading the IPs goes as follows
    > - ```192.168.50.10 - 192.168.50.19``` is for web,
    > - ```192.168.50.4 - 192.168.50.9``` for load balancers
    > - ```192.168.50.20+``` for databases
    > - go for ```192.168.50.30+``` for yours :wink:

#### Dev Deploy
In order to run post-deployment scripts such as database migrations, composer install/update and whatnot,
Ansible needs to know what your intensions are which is something you can do by specifying tags.

In ```Vagrantfile``` under the definition of the ```web``` machine you find this block of code:

```ruby
web.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'development-web.yml'
    ansible.sudo = true
    # ansible.tags = ['deploy']
end
```

This line represents the tags that you can pass to ansible when provisioning ```ansible.tags = ['deploy']```,
here's the list of available tags

##### Deploy Tags
run the provisioning after specifying your tags as mentioned earlier with the command ```vagrant provision web```,
in the case of
###### Artisan
- ```artisan-dump```

###### Database Migrations and Seeding
- ```db-migrate```
- ```db-seed```
- ```db-refresh```

###### Composer Install and Update
- ```composer-install```
- ```composer-update```
- ```composer-dump```

###### Custom Tags
Adding custom tags and their handlers in Ansible is pretty easy, take this example:

We want to add a handler that would change the permissions of ```app/storage``` to ```o+w```:

- open ```roles/dev-deploy/tasks/main.yml``` and add this snippet

```yaml
- name: open up app/storage for the world
  shell: echo changing permissions of app/storage
  notify:
      - open storage directory
  tags:
      - open-storage-directory
```

This will allow us to add the tag ```open-storage-directory``` to the provisioning of Ansible in ```Vagrantfile```
but yet we need to handle the ```notify``` that we're using, here goes:

- open ```roles/dev-deploy/handlers/main.yml``` and add this snippet

> the name should be the same as the value of ```notify```

```yaml
- name: open storage directory
  shell: chmod -R o+w app/storage chdir={{app.sites[0]['path']}}
```

Now we need to trigger this tag, in ```Vagrantfile``` change the web provisioning with ansible
part adding ```ansible.tags = ['open-storage-directory']``` and run ```vagrant provision web```

You can always make a mix of post-deploy tags like:

```ansible.tags = ['composer-update', 'db-migrate', 'open storage directory']

Done!

Installation with Docker+Vagrant (on your own risk)
-------------------

#### Docker (broken at the moment)
- open ```vagrant.docker.yml``` and modify ```source:``` to be your source code folder
- rename ```Vagrantfile``` to ```Vagrantfile.vagrant``` and ```Vagrantfile.docker``` to ```Vagrantfile```
    which is the one we'll be using
- we're ready to launch: ```vagrant up```
- when done and before moving on, make sure to uncomment the line
    ```ansible.skip_tags = ["docker-images", "docker-run"]``` in ```Vagrantfile```
    so that you don't build and run the images on every ```vagrant provision``` if needed

##### Setup
- we should now add some ssh configs to help us connect to our docker instances
    - open ```development``` and check the hosts used under each group name (the things in brackets), you will be able
    to ```ssh``` into any of these, but not just yet.
    - open ```~/.ssh/config``` and add the following **remember to set ```IdentityFile``` to the correct path**:
    ```bash
        Host vg.agency.stargate
            HostName localhost
            User root
            Port 6022
            IdentityFile /Users/Mulkave/Developer/Vinelab/Projects/agency/provisioning/docker_ssh

        Host vg.agency
            HostName localhost
            User root
            Port 6023
            IdentityFile /Users/Mulkave/Developer/Vinelab/Projects/agency/provisioning/docker_ssh

        Host vg.agency.db
            HostName localhost
            User root
            Port 6024
            IdentityFile /Users/Mulkave/Developer/Vinelab/Projects/agency/provisioning/docker_ssh
    ```
    - now we can connect to any of our instances, try it out: ```ssh vg.agency```

- now that we're done with launching our server instances, we need to configure them
    - ```ansible-playbook -i development development.yml```
    - answer with ```yes``` whenever asked ```Are you sure you want to continue connecting (yes/no)? yes```
