# Ronn-NG Developer's Guide

## Release checklist

1. Update the version in files
    1. `ronn-ng.gemspec` (update the release date there, too)
    1. `lib/ronn.rb`
1. Update `CHANGELOG.md` with the release date
1. Regenerate the man pages with `bundle exec rake man`
1. Run the tests one last time! `bundle exec rake test`
1. Commit the updated files
    1. Commit message format: "rel: vX.Y.Z"
1. Tag the release: `git tag vX.Y.Z`
1. `git push --tags`
1. Create the Release on GitHub Releases
1. Build and publish the gem to RubyGems
    1. `gem build ronn-ng.gemspec`
    1. `gem push ronn-ng-<version>.gem`
1. Update the ronn-ng formula in our [ronn-ng/homebrew-ronn-ng Homebrew tap repo](https://github.com/apjanke/homebrew-ronn-ng) and push it
1. TBD: Announce the release somewhere

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

The system Rubies in some OSes, especially macOS, are not suitable for doing Ruby development. Those are for the system's use. You'll need to set up a Ruby development environment. As of 2024-01, I'm using rbenv to create Ruby dev envs, and bundler on top of that to install the gems. Other Ruby env managers may well work, but I don't know them, and don't support them. The docs here assume that you're using rbenv the same way I am.

To set up a Ruby dev env for Ronn-NG in the manner that I use:

1. Install rbenv, and set up your shell to use it.
1. Do `rbenv install <version>` to install each Ruby version you want to test against.
1. Do `rbenv shell <version>` to activate an rbenv ruby.
1. Do `rm Gemfile.lock; bundle install` to install ronn-ng's gem dependencies in your rbenv Ruby.
1. Run locally: then you can `bundle exec rake test`, `bundle exec ./bin/ronn`, or whatever else.

I use `rbenv shell` instead of `rbenv local`, because Ronn-NG supports a range of Rubies (2.7 through 3.3, as of 2024-01) and tests against all of them. So I don't want to add a `.ruby-version` to the repo and fix it to a single version. The `Gemfile.lock` is generated against one particular ruby (currently 2.7), but that's just one reference and not the only one I want to run and test under.

As of 2024-01, I'm testing against Ruby: 2.7, 3.0, 3.1, 3.2, 3.3. I use the latest patch version of each minor version.

The `ronn-ng.gemspec` file uses pretty loose dependency version definitions, so each time you do this, you might pick up different versions of the gem dependencies, and that's normal.

### References: dev environment

* Ruby env setup
  * [Ruby setup on macOS](https://www.moncefbelyamani.com/the-definitive-guide-to-installing-ruby-gems-on-a-mac/)
  * <https://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac/#start-here-if-you-choose-the-long-and-manual-route>

## Running locally

You need to use special techniques to run `ronn` locally, entirely from the local repo and dev environment, instead of pulling stuff in from the main local system, including system-level installed gems and `ronn` itself.

This describes how to do it using an rbenv-managed Ruby dev environment. On some platforms, it may be possible to do this using the system Ruby and user-installed gems, but that's tricky and not covered here.

1. Activate your dev ruby with `rbenv local <version>`.
1. Install the gem dependencies: `rm Gemfile.lock; bundle install`
    1. `rm Gemfile.lock` to release versions, if needed (like when switching ruby versions).
    1. `bundle install` to actually install the gems.
1. `bundle exec ./bin/ronn [...]` to actually run it.

It would be nice for plain `./bin/ronn` or `ronn` with `./bin` on the `$PATH` to work in a bundler context, but I don't know how to do that.

## Running tests

Doing `bundle exec rake test` will run all the tests.

Do `RONN_QUIET_TEST=1 bundle exec rake test` for shorter output that omits the possibly-long results-diff outputs.

The `rake test` should be done against each of the supported Ruby versions we're developing and testing against. TODO: Add a script that automates that.

## Git commits

I like Git commit messages that have a "blah:" prefix to indicate what area of the code they did something to. If you're going to do commits or PRs, please consider wording your commit messages that way.

From 2019 to late 2023, I used "[blah]" instead of "blah:" prefixes. From 2023-11 on, I used "blah:" prefixes. Not sure which I like better; currently thinking "[blah]" might be preferable, because it seems more "scannable" when scrolling through Git commit history displays.

Prefixes I use as of 2024-01:

* `code` – Internal code stuff that doesn't change public-interface behavior, like refactorings. Build toolchain stuff goes here.
* `doc` – Documentation, both user and maintainer facing.
* `deps` – Dependencies, including gems, Ruby itself, and OS-installed packages.
* `rel` – Making releases.
* `tests` – Testing stuff.

Prefer long, detailed Git commit messages that describe both what the commit does and why it was done.

Terminology:

* "bump" means to upgrade the version of a dependency.
* "regen" means to "regenerate" derived things, as in regenerating the man pages from the `*.ronn` sources.