# SPDX-FileCopyrightText: 2024 Shun Sakai
#
# SPDX-License-Identifier: CC0-1.0

# Run default recipe
@_default:
    just -l

# Preview the contents
@preview:
    npx zenn-cli preview -p 8080

# Run the code formatter
@fmt:
    npx prettier -w articles books

# Run the linter
@lint:
    npx markdownlint articles books

# Run the linter for GitHub Actions workflow files
@lint-github-actions:
    actionlint -verbose
