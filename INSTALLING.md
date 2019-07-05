Ronn-NG Installation
====================

## Installation Process

### From a Package Manager

The best way to install Ronn-NG is with a package manager. This is currently
only supported on macOS, with [Homebrew](http://brew.sh). To install with `brew`:

```
brew tap apjanke/ronn-ng
brew install ronn-ng
```

### From RubyGems

Ronn-NG is distributed as a gem package, which can be used if you don't have
a supported package manager. Install with rubygems:

```
gem install ronn-ng
ronn --help
```

Ronn-NG includes completion definitions for bash and zsh, but these are not
installed into the system locations as part of the gem. You will need to figure 
out how to install those into your system to make them available in your shell.

A decent way to do this is probably to add symlinks to your system shell
completion directories pointing at the files in the installed gem.

In Zsh, you can do something like this:

```
ronn_dist_dir=$(dirname $(dirname $(gem which ronn-ng)))
ronn_zsh_dir="$ronn_dist_dir/completion/zsh"
ln -s "$ronn_zsh_dir/_ronn" /usr/local/share/zsh/site-functions
```

In Bash, something like this:

```
ronn_dist_dir=$(dirname $(dirname $(gem which ronn-ng)))
ronn_bash_dir="$ronn_dist_dir/completion/bash"
ln -s "$ronn_bash_dir/ronn" /usr/local/etc/bash_completion.d
```

You will need to redo these steps each time you upgrade `ronn-ng` or install
it into a different Ruby environment. Sorry for the inconvenience; this seems
to be a limitation of the `gem` installation mechanism.

If that `gem which` stuff doesn't work for you, you can `gem install gem-path`
and use `gem path ronn-ng` instead.


## Building from Source

Hacking? Install Ronn-NG from source.

Clone the git repository and put ronn/bin on your PATH:

```
git clone git://github.com/apjanke/ronn-ng
PATH=$(pwd)/ronn-ng/bin:$PATH
```

The following gems are required for ronn-ng development:
 * nokogiri
 * mustache
 * kramdown
 * rubocop
 * sinatra
 * rack
 * rake
 * test-unit

```
gem install nokogiri mustache kramdown rubocop sinatra rack rake test-unit
```

Or install them with bundler using the project's gem definition:

```
bundle install --with development
```

Then you should be able to make changes directly to your cloned repo and have
them be reflected in your active `ronn` command.

## Legacy Versions

Historical Ronn tarballs available at [the original Ronn repo](http://github.com/rtomayko/ronn/downloads).

```
curl -L http://github.com/rtomayko/ronn/downloads/0.6.6 | tar xvzf -
cd rtomayko-r*
ruby setup.rb
```
