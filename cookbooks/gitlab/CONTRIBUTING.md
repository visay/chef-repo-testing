# Contribute to the GitLab Cookbook

This guide details how to use issues and merge requests to improve GitLab.

-  [Contributor license agreement](#contributor-license-agreement)
-  [Security vulnerabilities](#security-vulnerability disclosure)
-  [Closing policy for issues and merge requests](#closing-policy-for-issues-and-merge-requests)
-  [Issue tracker](#issue-tracker)
-  [Merge requests](#merge-requests)

## Contributor license agreement

By submitting code as an individual you agree to the [individual contributor license agreement](doc/legal/individual_contributor_license_agreement.md). By submitting code as an entity you agree to the [corporate contributor license agreement](doc/legal/corporate_contributor_license_agreement.md).

## Security vulnerability disclosure

Please report suspected security vulnerabilities in private to support@gitlab.com, also see the [disclosure section on the GitLab.com website](http://www.gitlab.com/disclosure/). Please do NOT create publicly viewable issues for suspected security vulnerabilities.

## Closing policy for issues and merge requests

GitLab is a popular open source project and the capacity to deal with issues and merge requests is limited. Out of respect for our volunteers, issues and merge requests not in line with the guidelines listed in this document may be closed without notice.

Please treat our volunteers with courtesy and respect, it will go a long way towards getting your issue resolved.

Issues and merge requests should be in English and contain appropriate language for audiences of all ages.

## Issue tracker

The [issue tracker](https://gitlab.com/gitlab-org/cookbook-gitlab/issues) is only for obvious bugs or misbehavior. When submitting an issue please conform to the issue submission guidelines listed below. Not all issues will be addressed and your issue is more likely to be addressed if you submit a merge request which partially or fully addresses the issue.

Do not use the issue tracker for feature requests. We have a specific [feedback and suggestions forum](http://feedback.gitlab.com/forums/176466-general/category/77454-gitlab-cookbook) for this purpose.

Please send a merge request with a tested solution or a merge request with a failing test instead of opening an issue if you can.

### Issue tracker guidelines

Search for similar entries before submitting your own, there's a good chance somebody else had the same issue. Show your support with `:+1:` and/or join the discussion. Please submit issues in the following format (as the first post):

1. **Summary:** Summarize your issue in one sentence (what goes wrong, what did you expect to happen)
2. **Steps to reproduce:** How can we reproduce the issue
3. **Expected behavior:** Describe your issue in detail
4. **Observed behavior**
5. **Relevant logs and/or screenshots:** Please use code blocks (\`\`\`) to format console output, logs, and code as it's very hard to read otherwise.
6. **Versions** Which OS, Vagrant version, Vagrant plugins, Chef version and Ruby version are you using?
7. **Possible fixes**: If you can, link to the line of code that might be responsible for the problem

## Merge requests

We welcome [merge requests](https://gitlab.com/gitlab-org/cookbook-gitlab/merge_requests) with fixes and improvements to code, tests, and/or documentation.

### Merge request guidelines

If you can, please submit a merge request with the fix or improvements including tests. If you don't know how to fix the issue but can write a test that exposes the issue we will accept that as well. In general bug fixes that include a regression test are merged quickly while new features without proper tests are least likely to receive timely feedback. The workflow to make a merge request is as follows:

1. Fork the project
1. Create a feature branch
1. Write tests and code
1. It must contain passing `chefspec` tests
1. Test it on multiple platforms
1. Add your changes to the [CHANGELOG](CHANGELOG)
1. If you have multiple commits please combine them into one commit by [squashing them](http://git-scm.com/book/en/Git-Tools-Rewriting-History#Squashing-Commits)
1. Push the commit to your fork
1. Submit a merge request and explain in description what it does and which platforms it is run on and which platforms are untested
1. Find [issues](https://dev.gitlab.org/gitlab/cookbook-gitlab/issues) related to your merge request and mention them in the merge request description

We will accept merge requests if:

* The code has proper tests and all tests pass (or it is a test exposing a failure in existing code)
* It can be merged without problems (if not please use: `git rebase master`)
* It does not break any existing functionality
* It's quality code that conforms to the [Ruby](https://github.com/bbatsov/ruby-style-guide) and [Rails](https://github.com/bbatsov/rails-style-guide) style guides and best practices
* The description includes a motive for your change and the method you used to achieve it
* It is not a catch all merge request but rather fixes a specific issue or implements a specific feature
* It keeps the GitLab code base clean and well structured
* We think other users will benefit from the same functionality
* If it makes changes to the UI the merge request should include screenshots
* It is a single commit (please use `git rebase -i` to squash commits)

For examples of feedback on merge requests please look at already [closed merge requests](https://gitlab.com/gitlab-org/cookbook-gitlab/merge_requests?label_name=&milestone_id=&scope=&state=closed).
