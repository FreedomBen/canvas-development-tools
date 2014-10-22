canvas-development-tools
========================

Some handy scripts that I use to make life better while working on Canvas by Instructure.

**Script breakdown:**

1. **CODES.sh:** The Canvas Open Development Environment Script (CODES) will take any OS X, Arch Linux, Ubuntu, Fedora, or Linux Mint system from a base install to a fully setup environment for developing Canvas.  This script will do everything that the other scripts do individually, generally in a more robust fashion since the currently PATH, working directory, and state of the system are more predictable
2. **git-gerrit-submit:** This handy script should be copied to somewhere in your PATH.  After that, you can use the command `git gerrit-submit` to easily push the current changes to gerrit
3. **setup-new-repo.sh:** This script sets up a freshly cloned canvas repo by building assets, setting the gerrit hook, creating ctags, etc.  This script requires the others since it simply calls them to do its job
4. **add-custom-gems.sh:** This script adds a few custom gems that I like to use, such as colorize, which makes outputting color to the Rails log easier
5. **add-gerrit-hook.sh:** If you work for Instructure, Gerrit is mandatory.  This script adds a post-commit hook that automatically adds a gerrit change-id and does some other helpful checks
6. **build-assets.sh:** This script builds the canvas assets using rake
7. **create-database-config.sh: This script creates a basic database configuration for you
8. **generate-ctags.sh:** This script generates a fresh set of ctags for use with your favorite text editor
9. **initialize-databases.sh:** This script runs the db initialization commands
10. **set-ruby-version.sh:** This script writes the current ruby version to a .ruby_version file for use with chruby auto
