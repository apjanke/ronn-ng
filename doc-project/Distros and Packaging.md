# Distros and Packaging

This doc has notes about packaging Ronn-NG with various package managers, and about the distros (like Linux distros or Homebrew) which have picked up Ronn-NG for inclusion.

The distro packagers have picked up Ronn-NG on their own and created the packages for them, including the package definitions and patches for them. The Ronn-NG project doesn't maintain (or necessarily understand) these packaging mechanisms. This list is a reference, useful for finding the actual maintainers of the packaging stuff if you need to discuss that level of things, or to explore and learn about how they work.

We'd generally like to upstream any patches applied by package managers, unless they're very platform-specific. And if you're a distro packager who'd like us to do something to make packaging Ronn-NG easier for you, please let us know – email <floss@apjanke.net> or open an issue on [our GitHub repo issues page](https://github.com/apjanke/ronn-ng/issues).

## Distros

### Debian

* Package: [ronn](https://packages.debian.org/bookworm/ronn)
* Package: [ruby-ronn](https://packages.debian.org/bookworm/ruby-ronn)
* Source package: [ruby-ronn](https://packages.debian.org/source/bookworm/ruby-ronn) (produces both ruby-ronn and ronn packages?)
* Source repo: [ruby-ronn](https://salsa.debian.org/ruby-team/ruby-ronn)

| Distro Release | Ronn-NG Ver | Ruby Ver |
| -------------- | ----------- | -------- |
| 10 buster      | 0.8.0       | 2.5      |
| 11 bullseye    | 0.9.1       | 2.7      |
| 12 bookworm    | 0.9.1       | 3.1 ???  |
| 13 trixie      | 0.9.1       | 3.1 ???  |
| 14 sid         | TBD? / 0.9.1 | 3.1     |

Debian splits Ronn-NG into separate ronn ("tool") and ruby-ronn ("library") packages. Not sure why, or how that is done. It's not something I intended for Ronn-NG, and AFAICT, the original author Tomayko didn't either; Ronn doesn't seemed designed or documented for use as a Ruby library as opposed to a command.

Package definitions and patches are in the `debian` subdirectory in the repo.

Their package definition has a "watch" for new tags in my ronn-ng repo, so they'll notice when a new release comes out.

The Debian package for 0.9.1 had some patches. As of 2023's work on 0.10, the non-Debian-specific ones have all been upstreamed, so they can probably remove most patches for an 0.10.1 package. (In [#80](https://github.com/apjanke/ronn-ng/issues/80), [#87](https://github.com/apjanke/ronn-ng/issues/87) (Psych 4.0 compat), [#76](https://github.com/apjanke/ronn-ng/pull/76) (reproducible man pages with fixed datestamp).)

### Ubuntu

* Package: [ronn](https://packages.ubuntu.com/jammy/ronn)
* Package: [ruby-ronn](https://packages.ubuntu.com/jammy/ruby-ronn)
* Source package: [ruby-ronn](https://packages.ubuntu.com/source/jammy/ruby-ronn)
* Uses the Debian source repo: [Debian ruby-ronn](https://salsa.debian.org/ruby-team/ruby-ronn)

| Distro Release   | Ronn-NG Ver | Ruby Ver |
| ---------------- | ----------- | -------- |
| 20.04 LTS focal  | 0.8.0       | 2.7      |
| 22.04 LTS jammy  | 0.9.1       | 3.0      |
| 23.04 lunar      | 0.9.1       | 3.1      |
| 23.10 mantic     | 0.9.1       | 3.1      |
| noble            | TBD         |          |

Ubuntu is a derivative of Debian, so I think their packaging choices and actual package defnitions are just inherited from Debian.

### Fedora

* Package: [rubygem-ronn-ng](https://packages.fedoraproject.org/pkgs/rubygem-ronn-ng/rubygem-ronn-ng/)
* Package (classic Ronn): [rubygem-ronn](https://packages.fedoraproject.org/pkgs/rubygem-ronn/rubygem-ronn/)

| Distro Release   | Ronn-NG Ver | Ruby Ver |
| ---------------- | ----------- | -------- |
| Fedora 38        | 0.9.1       |          |
| Fedora 39        | 0.9.1       |          |

Fedora has both Ronn and Ronn-NG as distinct packages. The original rubygem-ronn only seems present in the EPEL 8 release; rubygem-ronn is in EPEL 8, Fedora 38, 39, and Rawhide. And the [spec for rubygem-ronn-ng](https://src.fedoraproject.org/rpms/rubygem-ronn-ng/blob/main/f/rubygem-ronn-ng.spec) says it obsoletes rubygem-ronn:

```text
Provides:       rubygem-ronn = %{version}-%{release}
Obsoletes:      rubygem-ronn < 0.7.3-20
```

### Arch Linux

* Package: [ruby-ronn-ng](https://archlinux.org/packages/extra/any/ruby-ronn-ng/)

### MacPorts

* Port: [rb-ronn-ng](https://ports.macports.org/port/rb-ronn-ng/details/)

MacPorts provides subports for different Ruby versions. Our tight dependency versioning probably makes that harder. That may be a reason to relax the ruby and gem version dependencies in the gemspec, allowing much oler versions even if I'm not testing against them.

### Homebrew

* Our Tap Formula: [ronn-ng/ronn-ng](https://github.com/apjanke/homebrew-ronn-ng)
* Core Formula (clasic Ronn, not Ronn-NG): [ronn.rb](https://github.com/Homebrew/homebrew-core/blob/master/Formula/r/ronn.rb)

Homebrew still uses the original Ronn, not Ronn-NG. As of 2024-01, they're on Ronn 0.7.3.

We provide a [custom ronn-ng Tap](https://github.com/apjanke/homebrew-ronn-ng) with formulae for installing Ronn-NG with brew. Users need to "tap" it first, and can then do `brew install ronn-ng`.

We do not actively test our custom Homebrew formula as part of our development and release process. We should probably start doing so.

## Packaging Considerations

As of 0.9.1 and especially 0.10.1, Ronn-NG's gem dependency versions are defined rather tightly, to versions that I have actually tested on and know work. That seems good for when you're shipping Ronn-NG as an "application" that expects dedicated bundled/vendored dependencies. But not all targets may be able to supply those, especially in combination with dependencies from other Ruby-based programs that define their own gem version range dependencies, in distro environments that supply the dependency gems like nokogiri or mustache as their own distro packages, so they may have a fixed single "current" version.

May want to relax those dependencies: set the minimum version for ruby and gem deps as low as I think I can go and have it still work (even with a couple issues), and don't cap the maximum versions or put exclusions unless I have actually seen issues with a that version.
