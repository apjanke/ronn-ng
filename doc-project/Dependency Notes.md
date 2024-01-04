# Ronn-NG Dependency Notes

Ronn-NG tries to allow a wide range of dependency versions in its gemspec, and be strict and even specific about its gem dependencies in deployment and testing scenarios. This will hopefully let users install it as a gem in a wide variety of environments, and let distro packagers fit it in with different fixed versions of packaged dependencies,  but be correct-er in testing and deployment in app or package form.

## Ruby version

I only develop and test on Ruby 2.6 and newer, and those are the only versions supported. Will probably be requiring >= 2.7 soon as of 2023.

Chose Ruby 2.6 as the minimum because those are the ones that come with bundler included, and I don't want to bother installing it there. (The default `gem install bundler` doesn't work; a version-specific `gem install bundler -v 2.3.26` might, but use of it tends to break due to bugs in early gem and bundler versions, and I don't want to deal with that.)

I mostly test on Ruby 2.7 or 3.x, because that's waht to seems to be in common use and distro shipping in 2023.

## Gem versions

I'm currently keeping the gem dependency versions in the gemspec as loose as I can, while everything still works (tests pass and I don't notice anything breaking), and keeping the min version high enough to pick up security fixes that I know about (mostly through Dependabot on GitHub). Specific reasons for those versions are noted in comments in the gemspec.

If you need to install it in an environment that only supplies older gems, edit the gemspec to relax the minimum version, and maybe it'll work? But it will be unsupported.

### nokogiri

We require nokogiri >= [1.14.3](https://github.com/sparklemotion/nokogiri/releases/tag/v1.14.3) because earlier versions have undesirable handling of tag names with ":" characters in them (which look like namespaces). I don't know if that's a bug or not; I assume so because it's a material behavior change in a patch version increment. That nokogiri version bumped its vendored libxml2 from 2.10.3 to 2.10.4. See [issue #102 "libxml 2.10+ compatibility for dot. and foo:colon angle-bracket syntax"](https://github.com/apjanke/ronn-ng/issues/102). Earlier libxml2 versions also have security vulnerabilities; that's why the [nokogiri 1.14.3 release notes](https://github.com/sparklemotion/nokogiri/releases/tag/v1.14.3) say they upgraded.
