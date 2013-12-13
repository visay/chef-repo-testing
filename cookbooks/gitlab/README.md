GitLab Cookbook
===============

Chef cookbook with recipes to install GitLab and its dependencies:

* GitLab: 6.3
* GitLab Shell: 1.7.9
* Ruby: 2.0.0p353
* Redis: 2.6.13
* Git: 1.7.12
* Nginx: 1.1.19
* PostgreSQL: 9.1.9
* MySQL: 5.5.34

### Compatible operating systems

Cookbook has been tested and it is known to work on:

* Ubuntu (12.04, 12.10)
* RHEL/CentOS (6.4)

## Installation

* [Development installation on a virtual machine with Vagrant](doc/development.md)

* [Production installation on Amazon Web Services (AWS) with Vagrant](doc/aws_vagrant.md)

* [Production installation with Chef Solo](doc/production.md)

If you want to do a production installation using AWS Opsworks please see the [cookbook for GitLab on AWS Opsworks repository](https://gitlab.com/gitlab-com/cookbook-gitlab-opsworks/blob/master/README.md).

## Database

Default database for this cookbook is `mysql`.
To override default credentials for the database supply the following json to the node:

```json
{
  "mysql": {
    "server_root_password": "rootpass",
    "server_repl_password": "replpass",
    "server_debian_password": "debianpass"
  },
  "gitlab": {
    "database_password": "datapass"
  }
}
```

To use `postgresql` override default credentials by supplying the following json to the node:

```json
{
  "posgtresql": {
    "password": {
      "postgres": "psqlpass"
    }
  },
  "gitlab": {
    "database_adapter": "postgresql",
    "database_password": "datapass",
  }
}
```

## Monitoring

Basic monitoring can be [setup with monit](doc/monit.md)

## Recipes

### clone

Clones the GitLab repository. Recipe uses the attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`.

### database_mysql

Use to setup mysql database. Available attributes are listed in `attributes/default.rb`.

### database_posgresql

Use to setup postgresql database. Available attributes are listed in `attributes/default.rb`.

### default

Default recipe, it includes two recipes: `setup` and `deploy`. Default recipe is being used to do the complete GitLab installation.

### deploy

Used to clone, configure, setup and start a GitLab instance. `deploy` recipe can be used with AWS OpsWorks to deploy GitLab to an instance.
To use with AWS OpsWorks:

1. Use a preset `Rails App Server` layer or create a custom one
1. Edit the layer
1. Under section `Custom Chef Recipes` and `Deploy` fill in `gitlab::deploy` and save

NOTE: Must be used in combination with `gitlab::setup` recipe.

### gems

This recipe decides what will be included and what will be ommited from the bundle install command and then it runs the bundle install.
Inclusion or exclusion is decided based on the database selected and environment, using attributes in `attributes/default.rb`

### git

Installs packages required for git and compiles it from source. Uses attributes provided in `attributes/git.rb`.

### gitlab_shell_clone

Clones the gitlab-shell repository. Recipe uses the attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`.

### gitlab_shell_install
Creates a gitlab-shell config.yml from attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`. Runs `gitlab-shell` install script and install it.

### install
Creates a gitlab config.yml, database.yml from attributes in `attributes/default.rb` and, depending on the environment set,
`attributes/development.rb` or `attributes/production.rb`. Creates GitLab required directories and sets permissions. Copies the example files
to their locations. Runs `db:setup`, `db:migrate`, `db:seed_fu` to prepare selected database for GitLab.

### nginx
Installs and configures nginx for usage.

### packages
Installs all GitLab dependency packages supplied in `attributes/default.rb`.

### ruby
Compiles ruby from source based on attributes in `attributes/default.rb`.

### setup

Includes `packages`, `ruby`, `users` and database recipes to prepare the server for GitLab.
`setup` recipe can be used with AWS OpsWorks to setup requirements for GitLab.
To use with AWS OpsWorks:

1. Use a preset `Rails App Server` layer or create a custom one
1. Edit the layer
1. Under section `Custom Chef Recipes` and `Setup` fill in `gitlab::setup` and save

NOTE: Must be used in combination with `gitlab::deploy` recipe.

### start

Enables gitlab service and starts GitLab.

### users

Creates a GitLab user called `git`.

## Testing the cookbook

First install the necessary gems

```bash
bundle install
```
To check for syntax errors run foodcritic:

```bash
foodcritic .
```
assuming that you are inside cookbook-gitlab directory.

Run tests with:

```bash
bundle exec rspec
```

## Acknowledgements

This cookbook was based on a [cookbbook by ogom](https://github.com/ogom/cookbook-gitlab), thank you ogom! We would also like to thank Eric G. Wolfe for making the [first cookbook for CentOS](https://github.com/atomic-penguin/cookbook-gitlab), thanks Eric!

## Contributing

Please see the [Contributing doc](CONTRIBUTING.md).

## Links

* [GitLab Installation](https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md)

## Authors

* [ogom](https://github.com/ogom)
* [Marin Jankovski](https://github.com/maxlazio)

## License

* [MIT](LICENSE)
