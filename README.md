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

```bash
bundle install
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
