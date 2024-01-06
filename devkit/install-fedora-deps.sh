#!/bin/bash
#
# install-fedora-deps - install Fedora dependencies for Ronn-NG
#
# This installs the RPM packages which Fedora uses as dependencies for Ronn-NG to supply
# its gem dependencies. This is an alternative to installing them with bundler, and lets
# you test Ronn-NG's source in this repo against the system gem packages it will use when
# built in to an RPM.
#
# This does not install the ronn-ng package (rubygem-ronn) itself, to avoid contaminating
# tests of the local Ronn-NG code in this repo with inconsistent versions loaded from the
# system-installed gems.

pkg_deps=(ruby rubygems-devel rubygem-test-unit
  rubygem-kramdown rubygem-kramdown-parser-gfm
  rubygem-mustache rubygem-nokogiri)
pkg_anti_deps=(rubygem-ronn-ng rubygem-ronn)

echo "Installing dep dnf pkgs: ${pkg_deps[@]}"
echo
sudo dnf install -y "${pkg_deps[@]}"

# Check that the anti-dependencies (main or conflicting code) are not installed
antis_shown=0
for pkg in "${pkg_anti_deps[@]}"; do
  if dnf list installed | cut -d ' ' -f 1 | grep -x "${pkg}.noarch" &> /dev/null; then
    if [[ $antis_shown == 0 ]]; then
      antis_shown=1
      echo
    fi
    echo "WARNING: anti-dep pkg ${pkg} is installed, and may interfere with testing"
  fi
done
if [[ $antis_shown == 1 ]]; then
  echo
fi

echo "Done."
echo
