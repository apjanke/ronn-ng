# Ronn-NG Developer's Guide

## Release checklist

* Update the version in files
  * `ronn-ng.gemspec` (update the release date there, too)
  * `lib/ronn.rb`
* Update `CHANGELOG.md` with the release date
* Regenerate the man pages with `bundle exec rake man`
* Run the tests one last time! `bundle exec rake test`
* Commit the updated files
  * Commit message: "rel: vX.Y.Z"
* Tag the release: `git tag vX.Y.Z`
* `git push --tags`
* Create the Release on GitHub Releases
* Build and publish the gem to RubyGems
  * `gem build ronn-ng.gemspec`
  * `gem push ronn-ng-<version>.gem`
* Update the ronn-ng formula in our [ronn-ng/homebrew-ronn-ng Homebrew tap repo](https://github.com/apjanke/homebrew-ronn-ng) and push it
* TBD: Announce the release somewhere

After the release, start development on the next release:

* Update the version in files
  * `ronn-ng.gemspec`
  * `lib/ronn.rb`
* Update `CHANGELOG.md` with a new "unreleased" section for the new work
* Regenerate the man pages again
  * `bundle exec rake man`
* Commit and push
  * Use commit message like "open development for next release"

TODO: Add instructions for prerelease/beta releases. Include a process for making a prerelease ronn-ng formula in our Homebrew tap.

## Setting up your dev environment

You need to have all of the gem dependencies installed, either in your system gem installation location, or user gems, or locally in this directory. `bundle install` will do something like that, but I haven't been able to figure out how to get that to work with `bundle exec rake test` without requiring you to install the gems and stuff in to the system location instead of a user or dir-local location.

### References: dev env

* Ruby env setup
  * [Ruby setup on macOS](https://www.moncefbelyamani.com/the-definitive-guide-to-installing-ruby-gems-on-a-mac/)
  * <https://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac/#start-here-if-you-choose-the-long-and-manual-route>

## Running locally

You need to use special techniques to run `ronn` locally, entirely from the local repo and dev environment, instead of pulling stuff in from the main local system, including system-level installed gems and `ronn` itself.

This describes how to do it using an rbenv-managed Ruby dev environment. On some platforms, it may be possible to do this using the system Ruby and user-installed gems, but that's tricky and not covered here.

1. Activate your dev ruby with `rbenv local <version>`.
2. Install the gem dependencies.
    1. `rm Gemfile.lock` to release versions, if needed (like when switching ruby versions).
    2. `bundle install` to actually install the gems.
3. `bundle exec ./bin/ronn [...]` to actually run it.

It would be nice for plain `./bin/ronn` or `ronn` with `./bin` on the `$PATH` to work in a bundler context, but I don't know how to do that.

## Running tests

`bundle exec rake test` will run all the tests.

Do `RONN_QUIET_TEST=1 bundle exec rake test` for shorter output that omits the possibly-long
diff outputs.
