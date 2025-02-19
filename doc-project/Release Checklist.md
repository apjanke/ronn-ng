# Ronn-NG Release Checklist

## Release checklist

1. Update the version in files
    1. `ronn-ng.gemspec` (update the release date there, too)
    1. `lib/ronn.rb`
1. Update `CHANGELOG.md` with the release date
1. Regenerate the man pages with `bundle exec rake man`
1. Run the tests one last time! `bundle exec rake test`
1. Test building the gem and then toss it
    1. `gem build ronn-ng.gemspec`
    1. `rm ronn-ng-*.gem`
1. Commit the updated files
    1. Commit message format: "[rel] vX.Y.Z"
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
  * Use commit message like "open development for next release (v0.x.y)"

TODO: Add instructions for prerelease/beta releases. Include a process for making a prerelease ronn-ng formula in our Homebrew tap.
