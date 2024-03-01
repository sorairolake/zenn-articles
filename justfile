# SPDX-FileCopyrightText: None
#
# SPDX-License-Identifier: CC0-1.0

alias all := default

# Run default recipe
default: fmt

# Run the code formatter
@fmt:
    npx prettier -w articles books

# Run the linter
@lint:
    npx markdownlint articles books

# Run the linter for GitHub Actions workflow files
@lint-github-actions:
    actionlint -verbose
