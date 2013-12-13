### Setting up monit

Monit is an open source utility for managing and monitoring, processes, programs, files, directories and filesystems on a UNIX system. Monit conducts automatic maintenance and repair and can execute meaningful causal actions in error situations.

### Installation

Recipe `gitlab::monit` is not included in the default chef run so in order to use it you will need to add it to the chef run list.

### Usage

There are two defined processes that are being monitored by monit -  sidekiq and unicorn.

#### Sidekiq

If sidekiq is "stuck" and it is using more than 225MB of RAM or if it is using 40% of CPU cycles(for 2 core machine that means 80% of a single core) monit will restart sidekiq.
If 5 restarts occur, monit will notify via email.
Attributes needed by default are:

```
{
  gitlab_user: "git",
  gitlab_path: "/home/git/gitlab",
  sidekiq_pid_path: "/home/git/gitlab/tmp/pids/sidekiq.pid",
  notify_email: "monitrc@localhost"
}
```

#### Unicorn

If unicorn is using more than 1GB of ram or 80% of CPU monit will restart unicorn. It will also notify using notify email.

Attributes needed by default are:

```
{
  gitlab_user: "git",
  gitlab_path: "/home/git/gitlab",
  unicorn_pid_path: "/home/git/gitlab/tmp/pids/unicorn.pid",
  notify_email: "monitrc@localhost"
}
```
#### Monit Web interface

Web interface is also enabled and you can use this to have a nice overview of monitored processes. If you need to enable any of the defaults you will have to supply node attributes:

```json
{
  "monit": {
    "web_interface": {
      "enable": true,
      "port": 2812,
      "address": "localhost",
      "allow": ["localhost", "admin:b1gbr0th3r"]
    }
  }
}
```
*Note* above listed attributes are the default so if you are satisfied with them there is no need to supply any attributes to the node.

#### Email settings

Monit will use email client installed on the server by default. If you want to use a different setup you will need to supply node attributes:

```json
{
  "monit": {
      "mail": {
        "hostname": "localhost",
        "port": 25,
        "username": nil,
        "password": nil,
        "from": "monit@$HOST",
        "subject": "$SERVICE $EVENT at $DATE",
        "message": "Monit $ACTION $SERVICE at $DATE on $HOST,\n\n$DESCRIPTION\n\nDutifully,\nMonit",
        "security": nil,  # 'SSLV2'|'SSLV3'|'TLSV1'
        "timeout ": 30
      }
    }
  }
}
```
*Note* above listed attributes are the default so if you are satisfied with them there is no need to supply any attributes to the node.
