### Development installation on a virtual machine with Vagrant

### Requirements

* [VirtualBox](https://www.virtualbox.org)
* [Vagrant 1.3.x](http://vagrantup.com)
* The NFS packages for the synced folder of Vagrant. These are already installed if you are using Mac OSX and not necessary if you are using Windows. On Linux install them by running:

```bash
sudo apt-get install nfs-kernel-server nfs-common portmap
```

Make sure to use Vagrant v1.3.x. Do not install Vagrant via rubygems.org as there exists an old gem which will probably cause errors. Instead, go to [Vagrant download page](http://downloads.vagrantup.com/) and install a version ~> `1.3.0`.

On OS X you can also choose to use [the (commercial) Vagrant VMware Fusion plugin](http://www.vagrantup.com/vmware) instead of VirtualBox.

### Installation

`Vagrantfile` already contains the correct attributes so in order use this cookbook in a development environment following steps are needed:

1. Check if you have a gem version of Vagrant installed:

```bash
gem list vagrant
```

If it lists a version of vagrant, remove it with:

```bash
gem uninstall vagrant
```

Next steps are:

```bash
gem install berkshelf
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-bindfs
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git
cd ./cookbook-gitlab
vagrant up --provision
```

By default the VM uses 1.5GB of memory and 2 CPU cores. If you want to use more memory or cores you can use the GITLAB_VAGRANT_MEMORY and GITLAB_VAGRANT_CORES environment variables:

```bash
GITLAB_VAGRANT_MEMORY=2048 GITLAB_VAGRANT_CORES=4 vagrant up
```

**Note:**
You can't use a vagrant project on an encrypted partition (ie. it won't work if your home directory is encrypted).

You'll be asked for your password to set up NFS shares.

### Running the tests

Once everything is done you can log into the virtual machine and run the tests as the git user:

```bash
vagrant ssh
cd /home/git/gitlab/
bundle exec rake gitlab:test
```

### Start the Gitlab application

```bash
cd /home/git/gitlab/
bundle exec foreman start
```

You should also configure your own remote since by default it's going to grab
gitlab's master branch.

```bash
git remote add mine git://github.com/me/gitlabhq.git
# or if you prefer set up your origin as your own repository
git remote set-url origin git://github.com/me/gitlabhq.git
```

#### Accessing the application

`http://0.0.0.0:3000/` or your server for your first GitLab login.

```
admin@local.host
5iveL!fe
```

#### Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

```bash
vagrant suspend
```

then, resume to hack again

```bash
vagrant resume
```

Run

```bash
vagrant halt
```

to shutdown the virtual machine, and

```bash
vagrant up
```

to boot it again.

You can find out the state of a virtual machine anytime by invoking

```bash
vagrant status
```

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

```bash
vagrant destroy # DANGER: all is gone
```

### OpenLDAP

If you need to setup OpenLDAP in order to test the functionality you can use the [basic OpenLDAP setup guide](doc/open_LDAP.md)

### Updating

The gitlabhq version is _not_ updated when you rebuild your virtual machine with the following command:

```bash
vagrant destroy && vagrant up
```

You must update it yourself by going to the gitlabhq subdirectory in the gitlab-vagrant-vm repo and pulling the latest changes:

```bash
cd gitlabhq && git pull --ff origin master
```

A bit of background on why this is needed. When you run 'vagrant up' there is a checkout action in the recipe that points to [gitlabhq repo](https://github.com/gitlabhq/gitlabhq). You won't see any difference when running 'git status' in the cookbook-gitlab repo because the cloned directory is in the [.gitignore](https://gitlab.com/gitlab-org/cookbook-gitlab/blob/master/.gitignore). You can update the gitlabhq repo yourself or remove the home_git so the repo is checked out again.
