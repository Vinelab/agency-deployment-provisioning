# Provisioning Agency

## Production
follow these steps to have an ```Agency``` instance running in production

## Development
setup your machine for some magic!

### Requirements
- [vagrant](https://docs.vagrantup.com/v2/installation/)
- [ansible 1.5+](http://docs.ansible.com/intro_installation.html)

### Installation
- clone this repository
- open ```vagrant.yml``` and modify ```source:``` to be your code folder
- download any CentOS 64-bit image from [Vagrant boxes](http://www.vagrantbox.es)
, minimal preferred
- add it with the following command: ```vagrant box add CentOS64 [url]```
- then ```vagrant init CentOS64```
