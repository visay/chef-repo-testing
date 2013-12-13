Gitlab-Vagrant-VM OpenLDAP setup
=================

Description
-----------

This guide will help you setup OpenLDAP in case you need an LDAP server in your dev environment for GitLab.
The reason why OpenLDAP is not installed by default in GitLab-Vagrant-VM is that it would extend the time needed for creating the dev box and not everyone needs LDAP.
However, it would be great if somebody could add this as a recipe to the Chef cookbook so it is installed automatically.

# Important notes
This guide is very basic and any improvements are welcome!

**Note:**
During this installation some files will need to be edited manually.
If you are familiar with vim set it as default editor with the commands below.
If you are not familiar with vim please skip this and keep using the default editor.

    # Install vim and set as default editor
    sudo apt-get install -y vim
    sudo update-alternatives --set editor /usr/bin/vim.basic

Setup
-----------
Login to your Vagrant machine

```bash
vagrant ssh
```

Add LDAP domain name to `/etc/hosts`

```bash
sudo editor /etc/hosts
```

and populate it with:

```
192.168.3.14 ldap.gitlab.dev ldap gitlab.dev
```


Update packages:

```bash
sudo apt-get update
```

and install required:

```bash
sudo apt-get install slapd ldap-utils -y
```

This will prompt a setup window so we need to populate it with the correct credentials.

When asked for administrator password use `gitlabldap`.
Repeat the password to confirm it.

We will use the advantage of slapd setup to fully configure LDAP instead of filling in the details by hand in a text file:

```bash
sudo dpkg-reconfigure slapd
```
Answer the following questions:

You will be asked to omit OpenLDAP server configuration: `No`
Under DNS domain name fill in: `gitlab.dev`
Under organization name fill in: `gitlab.dev`
Under administrator password fill in: `gitlabldap`
Repeat password: `gitlabldap
Database backend to use, select: `HDB`
Do you want database to be removed when slapd is purged: `Yes`
Move old database, choose: `Yes`
Allow LDAPv2 protocol, choose: `No`

** If at any point you get the error: **

```
ldap_bind: Invalid credentials (49)
```

configure slapd again.

Next, add index to make lookup easier, create a file index.ldif

```bash
editor index.ldif
```

and populate with the following:

```
dn: olcDatabase={1}hdb,cn=config
changetype: modify
add: olcDbIndex
olcDbIndex: uid eq,pres,sub
```

and add it to ldap database:

```bash
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f index.ldif
```

This should produce the following output:

```
modifying entry "olcDatabase={1}hdb,cn=config"
```
If this is not the case recheck your steps and try again.

You can verify that all is working:

```bash
sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=config '(olcDatabase={1}hdb)' olcDbIndex
```
This should produce the following output:

```
dn: olcDatabase={1}hdb,cn=config
olcDbIndex: objectClass eq
olcDbIndex: uid eq,pres,sub
```
If this is not the case recheck your steps and try again.

Next step is to create an ldap user. 
Create `base.ldif` 

```bash
editor base.ldif
```

and populate with:

```
dn: ou=Users,dc=gitlab,dc=dev
objectClass: organizationalUnit
ou: Users

dn: uid=jsmith,ou=Users,dc=gitlab,dc=dev
objectClass: organizationalPerson
objectClass: person
objectClass: top
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: jsmith
sn: Smith
givenName: John
cn: John Smith
displayName: John Smith
uidNumber: 10000
gidNumber: 10000
userPassword: test
gecos: John Smith
loginShell: /bin/bash
homeDirectory: /profiles/jsmith
mail: john.smith@example.com
telephoneNumber: 000-000-0000
st: NY
manager: uid=jsmith,ou=Users,dc=gitlab,dc=dev
shadowExpire: -1
shadowFlag: 0
shadowWarning: 7
shadowMin: 8
shadowMax: 999999
shadowLastChange: 10877
title: System Administrator
```

Add the user to the LDAP database:

```bash
ldapadd -x -D cn=admin,dc=gitlab,dc=dev -w gitlabldap -f base.ldif
```

This should produce the following output:

```
adding new entry "ou=Users,dc=gitlab,dc=dev"

adding new entry "uid=jsmith,ou=Users,dc=gitlab,dc=dev"
```
If this is not the case recheck your steps and try again.

To confirm that the user is in LDAP, use:

```bash
ldapsearch -x -LLL -b dc=gitlab,dc=dev 'uid=jsmith' uid uidNumber displayName
```
and that should produce the output that looks like:

```
dn: uid=jsmith,ou=Users,dc=gitlab,dc=dev
uid: jsmith
displayName: John Smith
uidNumber: 10000
```
This would complete setting up the OpenLDAP server. Only thing that is left to do is to give the correct details to GitLab.
Under `gitlab.yml` there is a LDAP section that should look like this:

```
  ## LDAP settings
  ldap:
    enabled: true
    host: 'gitlab.dev'
    base: 'dc=gitlab,dc=dev'
    port: 389
    uid: 'uid'
    method: 'plain' # "ssl" or "plain"
    bind_dn: 'dc=gitlab,dc=dev'
    password: 'gitlabldap'
```

Navigate to `/vagrant/gitlabhq/` and start the GitLab instance with:

```
bundle exec foreman start
```

If you now navigate to `http://192.168.3.14:3000/` and fill in the sign in page under the LDAP section with:

`username`: jsmith
`password`: test

you will be authenticated with OpenLDAP server and logged into GitLab.
