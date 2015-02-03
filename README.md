# github-activity

## Overview

GitHub activity is a small Ruby application that allows one to list all commits for a given set of repos for a given date range.

## Setup

1. Obtain a GitHub personal access token https://help.github.com/articles/creating-an-access-token-for-command-line-use
2. Clone the repo
`$ git clone https://github.com/ashmckenzie/github-activity`
3. Install gems
`$ bundle install`

## Running

```bash
$ GITHUB_API_TOKEN='<token>' ./activity.rb --org <org> --date-from <YYYY-MM-DD> --date-to <YYYY-MM-DD>
```

## Output

A file with the format `output_<org>_<date_from>-<date_to>.csv` will be created.

## Notes

It may take a while for large organisations due to the GitHub API being paginated (and max 100 results per page).
