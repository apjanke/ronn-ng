# Ronn-NG CHANGELOG

## 0.10.2 (unreleased)

* Fix bad link to `ronn(1)` in README. ([#128](https://github.com/apjanke/ronn-ng/pull/128))
* Officially support Ruby 3.x, removing "Ruby 3.x support is a work in progress" note. ([#116](https://github.com/apjanke/ronn-ng/pull/116))
* Require `fileutils` explicitly to avoid broken tests under Ruby 3.4+. ([#124](https://github.com/apjanke/ronn-ng/issues/124))
* Bump dependencies.

## 0.10.1 (2024-01-08)

This release is focused on bug fixes and updating library dependencies, to get Ronn-NG building and working correctly on recent Linux and macOS releases.

Note: 0.10.1 is the first 0.10.x release, because Ronn-NG 0.10.0 does not exist.

### Features and Additions

* Switch to GitHub Flavored Markdown ([#53](https://github.com/apjanke/ronn-ng/pull/53))
  * Fixes code block rendering
* doc: Reformat Changelog to match common gem and keep-a-changelog conventions
  * NOTE: Renamed `CHANGES` to `CHANGELOG.md`. Packagers will need to update specs.
* Bump Ruby to 2.7, gem deps to latest minor versions
* Tweak `ronn --version` output: remove GitHub URL and format it as "ronn \<ver\> (Ronn-NG)"

### Bug Fixes

* Relaxed and fixed dependency versions ([#108](https://github.com/apjanke/ronn-ng/issues/108))
* Revert `\[ci]` back to `\(bu)` ([#51](https://github.com/apjanke/ronn-ng/pull/51))
* Fix single-quote escaping ([#55](https://github.com/apjanke/ronn-ng/issues/55))
* Elide HTML comments when producing roff output ([#65](https://github.com/apjanke/ronn-ng/issues/65))
* Remove non-portable `more -i` option ([#71](https://github.com/apjanke/ronn-ng/issues/71))
* Fix charset (utf-8) in HTML output's Content-Type ([#83](https://github.com/apjanke/ronn-ng/pull/83))
* Psych 4.0 test fix, Ruby 3.x support (from n-ronn) ([#87](https://github.com/apjanke/ronn-ng/issues/87))
* Fix test failure for angle-bracket items with namespace-like "foo:" prefixes ([#102](https://github.com/apjanke/ronn-ng/issues/102))
  * Inclusion of the "foo:" is now considered correct, matching current code behavior

## 0.10.0 (never released)

Doesn't exist due to a RubyGems publishing mistake.

## 0.9.1 (2020-04-09)

* Fix underlining issue ([#41](https://github.com/apjanke/ronn-ng/pull/41))

## 0.9.0 (2019-12-21)

* Migrate to kramdown from rdiscount for the underlying Markdown library
* Minor output formatting and documentation improvements

## 0.8.2 (2019-03-05)

* Fixes packaging error in 0.8.1

## 0.8.1 (2019-03-05)

* Fix URL hyphenation bug ([#23](https://github.com/apjanke/ronn-ng/issues/23))
* Fix ordered-list bustication. ([#24](https://github.com/apjanke/ronn-ng/issues/24))

## 0.8.0 (2018-12-25)

### Features

* Add tables support.
* Add --output-dir option.
* Migrate from Hpricot to Nokogiri.

### Bug Fixes

* Lint & Rubocop fixes
* Support file names with periods in the name section

## 0.7.4 (2018-12-22)

* Forked Ronn-NG from original Ronn

### Bug Fixes

* Fix test for HTML meta elements ([#4](https://github.com/apjanke/ronn-ng/issues/4))
* Fix circumflex rendering ([#5](https://github.com/apjanke/ronn-ng/issues/4))

## Original Ronn changelog

The following sections are the changes from the original Ronn project, before Ronn-NG was forked from it. They were pulled in from its existing CHANGES file and reformatted.

## 0.7.3 (2010-06-24)

* Fixed a major bug in roff output due to overly aggressive doublequote
  escaping. Paragraphs and code blocks were not being displayed if they
  included a double-quote character. (rtomayko, pawelz)

## 0.7.0 (2010-06-21)

* HTML: Manual references (like 'grep(1)', 'ls(1)', etc.) are now hyperlinked
  based on a set of name -> URL mappings defined in an index.txt file. The index
  may also define links to things that aren't manuals for use in markdown
  reference-style links. See the ronn(1) manual on LINK INDEXES for more
  inforation: <http://rtomayko.github.com/ronn/ronn.1.html#LINK-INDEXES>
  (rtomayko)

* ROFF: Fixed a bug where multiple dot characters (.) at the beginning of a
  line were not being escaped properly and were not displayed when viewed
  in the terminal. (rtomayko)

* ROFF: Non-breaking space characters (&nbsp;) can now be used to control line
  wrap in roff output. (rtomayko)

* ROFF: Named HTML entities like &bull;, &trade;, &copy;, and &mdash; are now
  converted to their roff escaped equivalents. (rtomayko)

* An undocumented --markdown format option argument has been added to ronn(1).
  When given, ronn generates a <name>.<section>.markdown file with the
  post-processed markdown text. This is mostly useful for debugging but may be
  useful for converting ronn-format to 100% compatible markdown text.
  (rtomayko)

* The ronn(5) manpage is now known as ronn-format(7) (section 5 is limited
  to configuration files and stuff like that historically). The old ronn(7)
  manpage, which was really just the README, has been removed.
  (rtomayko)

* Performance improvements. Fixed a few cases where HTML was being reparsed
  needlessly, tuned dom selectors, ... (rtomayko)

## 0.6.6 (2010-06-13)

Small bug fix release fixes whitespace stripping between adjacent
inline elements in roff output (adamv, rtomayko)

## 0.6 (2010-06-13)

### Features

* HTML: New styling system:
    ronn --style=toc,print program.1.ronn
    ronn -s dark,toc,/path/to/custom.css man/*.ronn

  The --style (-s) option takes a list of CSS stylesheets to embed into the
  generated HTML. Stylesheets are inserted in the order specified and can use
  the cascade to add or remove visual elements.

  Ronn ships with a few built in styles: toc, dark, 80c, and print. You can
  insert your own by giving the path or manipulating the RONN_STYLE environment
  variable.

  See ronn(1) for full details on all of these things (rtomayko)

* HTML: It's now possible to generate a Table Of Contents of manpage sections.
  The TOC is disabled by default. To enable it: ronn --style=toc file.ronn
  (sunaku)

* HTML: The RONN_LAYOUT environment variable can be used to apply a custom
  mustache layout template:

  RONN_LAYOUT=mine.mustache ronn man/great-program.1.ronn

  See lib/ronn/template/default.html for default markup and features
  (defunkt)

* HTML: All heading elements include page anchor id attributes to make
  it possible to link to a specific manpage section (sunaku)

* HTML: Markdown reference links can be used to refer to sections. To link
  to the SEE ALSO section of the current manpage, use: [SEE ALSO][], or [to
  control the link text][SEE ALSO], or even [use the relative URL](#SEE-ALSO).
  (rtomayko)

* HTML: 80 character terminal style: ronn -s 80c file.ronn -- precisely
  emulates a 80c terminal (sunaku)

* HTML: Various appearance changes to the default stylesheet: smaller type
  with consistent vertical baseline; darker type for more contrast; em, var,
  and u are italic instead of underline (rtomayko)

* HTML: Various print stylesheet tweaks, including hyperlinks and layout
  enhancements (sunaku)

* ROFF: ronn --warnings (-w) shows troff warnings on stderr when building
  or viewing manuals. (rtomayko)

* ROFF: Ordered lists. (sunaku)

* ROFF: URLs for hyperlinks are shown immediately after hyperlink text.
  (sunaku)

* The RONN_MANUAL, RONN_ORGANIZATION, and RONN_DATE environment variables
  establish the default values of the --manual, --organization, and --date
  options (rtomayko)

### Bug Fixes

* ROFF: Don't crash with empty preformatted blocks (sunaku)

* ROFF: A whole bunch of weird whitespace related problems in roff output,
  such as the first line of definition lists being indented by two
  characters (rtomayko)

* ROFF: All ['".] characters are backslash escaped in roff output. These
  characters are used for various roff macro syntax (rtomayko)

### Deprecations, Obsoletions

* The ronn(1) command line interface has changed in ways that are not
  backward-compatible with previous versions of ronn. The --build option is
  assumed when one or more .ronn files is given on the command line. Previous
  versions write generated content to standard output with no explicit --build
  options.

  The default behavior when no files are given remains the same as previous
  versions: ronn source text is read from stdin and roff is written to stdout.

  See `ronn --help' or the ronn(1) manual for more on command line interface
  changes.

  (rtomayko, defunkt)

* HTML: Ronn no longer uses a specific monospace font-family; the system
  default monospace font is used instead. Use 'ronn --style' to set up a font
  stack (rtomayko)

* HTML: The following HTML elements are deprecated and will be removed at some
  point: div#man, div#man ol.man, div#man ol.head, div#man ol.man.

  The .mp, .man-decor, .man-head, .man-foot, .man-title, and .man-navigation
  classes should be used instead (rtomayko)

* The markdown(5) manpage is no longer shipped with the ronn package. It is
  shipped with the latest version of rdiscount, however.
  (rtomayko, sunaku)

## 0.5 (2010-04-24)

* Fixed a bug in roff output where multiple successive newlines were being
  collapsed into a single newline in preformatted output.

* Hexadecimal and decimal entity references generated by the Markdown to HTML
  conversion are now properly decoded into normal characters in roff output.

* The compatibility shims that allowed the ronn command to be invoked as "ron",
  and the ronn library to be required as "ron", have been removed.

## 0.4 (2010-03-08)

* Ron has been renamed "Ronn", including the "ronn" command and the "ronn"
  library. Compatibility shims are included in this release but will be removed
  in the next release.

* The hpricot library is now used for HTML hackery instead of the nokogiri
  library. The hpricot library is preferred because it doesn't depend on external
  system dependencies.
