# github-activity

## Overview

GitHub activity is a small Ruby application that allows one to list all commits for a given set of repos for a given

```bash
$ GITHUB_API_TOKEN='<token>' ./activity.rb --org <org> --date-from 2015-01-31 --date-to 2015-01-31
=========================================
Commits between 2015-01-01 and 2015-01-31
=========================================
...
```

## Setup

1. Obtain a GitHub personal access token - https://help.github.com/articles/creating-an-access-token-for-command-line-use
2. Clone the repo
```bash
$ git clone https://github.com/ashmckenzie/github-activity
```
3. Install gems
```bash
$ bundle install
```

## Running

```bash
$ GITHUB_API_TOKEN='<token>' ./activity.rb --org <org> --date-from 2015-01-31 --date-to 2015-01-31
=========================================
Commits between 2015-01-01 and 2015-01-31
=========================================
...
```

## Output

A file with the format `output_<org>_<date_from>-<date_to>.csv` will be created.

## Notes

It may take a while for large organisations due to the GitHub API being paginated (and max 100 results per page).
