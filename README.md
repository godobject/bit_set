BitSet
======

[![Build Status](https://secure.travis-ci.org/god_object/bit_set.png)](
https://secure.travis-ci.org/god_object/bit_set)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/godobject/bit_set)

* [Documentation][docs]
* [Project][project]

   [docs]:    http://rdoc.info/github/god_object/bit_set/
   [project]: https://github.com/god_object/bit_set/

Description
-----------

BitSet is a Ruby library implementing a bit set structure with labeled digits
and binary logic operators. Additionally it allows to create precached
configurations of BitSets which also allow the String representation to be
customized easily.

Features / Problems
-------------------

This project tries to conform to:

* [Semantic Versioning (2.0.0-rc.1)][semver]
* [Ruby Packaging Standard (0.5-draft)][rps]
* [Ruby Style Guide][style]
* [Gem Packaging: Best Practices][gem]

   [semver]: http://semver.org/
   [rps]:    http://chneukirchen.github.com/rps/
   [style]:  https://github.com/bbatsov/ruby-style-guide
   [gem]:    http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices

Additional facts:

* Written purely in Ruby.
* Documented with YARD.
* Intended to be used with Ruby 1.9.3 or compatible.
* Cryptographically signed gem and git tags.
* This library was developed as part of the PosixMode project.

Shortcomings and problems:

* BitSets with numbered but unnamed digits can't currently be handled.
* The library is optimized for usability and not for computational efficiency.

If you have solved any of these feel free to submit your changes back.

Synopsis
--------

This documentation defines the public interface of the software. Don't rely
on elements marked as private. Those should be hidden in the documentation
by default.

This is still experimental software, even the public interface may change
substantially in future releases.

### Loading

In most cases you want to load the library by the following command:

~~~~~ ruby
require 'bit_set'
~~~~~

In a bundler Gemfile you should use the following:

~~~~~ ruby
gem 'bit_set'
~~~~~

If you want to be able to simply call the class names inside the GodObject
namespace you can include it into the current scope by executing the following
statement:

~~~~~ ruby
include GodObject
~~~~~

The following documentation assumes that you did include the namespace.

### Creating a Configuration

A configuration defines the amount of bits in the set and defines a unique name
for each. The simplest way to create a configuration is just providing a list
of symbols. In the concrete bit sets, each digit will then be represented by a
"1" if it is enabled and a "0" if it is disabled.

~~~~~ ruby
BitSet::Configuration.new([:red, :green, :blue])
~~~~~

Instead you can also provide each digit with a custom enabled representation.
The given String will be used to represent the specific digit when it is
enabled. In case it is disabled a "-" will be displayed then.

~~~~~ ruby
pixel_config = BitSet::Configuration.new(
  red: 'r',
  green: 'g',
  blue: 'b'
)
~~~~~

One further option is to provide each digit with both an enabled and a disabled
representation.

~~~~~ ruby
BitSet::Configuration.new(
  red: ['r', 'o'],
  green: ['g', '!'],
  blue: ['b', 'x']
)
~~~~~

### Creating a BitSet

To now create an actual BitSet with this configuration you should call the
following:

~~~~~ ruby
bitset = pixel_config.new
# => #<GodObject::BitSet: "---">
~~~~~

If you want to provide an initial state for the BitSet you can either list all
enabled digits like this:

~~~~~ ruby
bitset = pixel_config.new(:red, :blue)
# => #<GodObject::BitSet: "r-b">
~~~~~

Or you can set the initial state by giving an integer representation like this:

~~~~~ ruby
bitset = pixel_config.new(6)
# => #<GodObject::BitSet: "rg-">
~~~~~

Additionally it is possible to create a BitSet by providing a
BitSet::Configuration object directly:

~~~~~ ruby
bitset = BitSet.new(:blue, pixel_configuration)
# => #<GodObject::BitSet: "--b">
~~~~~

Or by creating a Configuration definition on-the-fly:

~~~~~ ruby
bitset = BitSet.new(:green, red: 'r', green: 'g', blue: 'b')
# => #<GodObject::BitSet: "-g-">
~~~~~

### Examing a BitSet

Each BitSet can be asked for the state of its individual digits:

~~~~~ ruby
bitset.red?
# => false

bitset.green?
# => true

bitset.blue?
# => false
~~~~~

Or in a slightly different way:

~~~~~ ruby
bitset[:red]
# => false

bitset[:green]
# => true

bitset[:blue]
# => false
~~~~~

You can also get a complete state-containing hash by the following:

~~~~~ ruby
bitset.state
# => {:red=>false, :green=>true, :blue=>false}
~~~~~

Or a Set of all enabled/disabled digits:

~~~~~ ruby
bitset.enabled_digits
# => #<Set: {:green}>

bitset.disabled_digits
# => #<Set: {:red, :blue}>
~~~~~

A String representation can be generated in the usual way:

~~~~~ ruby
bitset.to_s
# => "-g-"
~~~~~

By default this will generate the long version, with both the enabled and the
disabled digits represented. A short variant is available as long as each digit
in the configuration has a unique enabled representation.

~~~~~ ruby
bitset.to_s(:short)
# => "g"
~~~~~

The Integer representation of the BitSet is as well available in a
straight-forward way:

~~~~~ ruby
bitset.to_s
# => 2
~~~~~

To gain access to the Configuration of the BitSet just use the following:

~~~~~ ruby
bitset.configuration
# => 2
~~~~~

### Comparison

BitSets are considered equal when their state and configuration are equal.
BitSet::Configurations are considered equal when they have the same list of
digits, without considering their String representations.

Using the #eql? method for comparison also checks for class family
compatibility.

### Operations

A set of operations can be used upon BitSets. Notice that BitSets are immutable
so that the results of the operations are always new BitSet objects.

Each digit's state in a BitSet can be inverted like the following:

~~~~~ ruby
bitset.invert
# => #<GodObject::BitSet: "r-b">
~~~~~

You can combine the enabled digits of two BitSets by adding them together:

~~~~~ ruby
pixel_config.new(:red) + pixel_config.new(:red, :blue)
# => #<GodObject::BitSet: "r-b">
~~~~~

To disable all digits in a BitSet that are enabled in another you can subtract
them from one another:

~~~~~ ruby
pixel_config.new(:red, :blue) - pixel_config.new(:green, :blue)
# => #<GodObject::BitSet: "r--">
~~~~~

To produce a BitSet which has only those digits enabled which are enabled on
both given BitSets you can calculate the intersection:

~~~~~ ruby
pixel_config.new(:red, :blue) ^ pixel_config.new(:green, :blue)
# => #<GodObject::BitSet: "--b">
~~~~~

An to only have those digits enabled in the result which are enabled on only
one of the given BitSets, calculate the symmetric difference:

~~~~~ ruby
pixel_config.new(:red, :blue).symmetric_difference(pixel_config.new(:green, :blue))
# => #<GodObject::BitSet: "rg-">
~~~~~

Requirements
------------

* Ruby 1.9.3 or compatible

Installation
------------

On *nix systems you may need to prefix the command with sudo to get root
privileges.

### High security (recommended)

There is a high security installation option available through rubygems. It is
highly recommended over the normal installation, although it may be a bit less
comfortable. To use the installation method, you will need my [gem signing
public key][gemkey], which I use for cryptographic signatures on all my gems.

Add the key to your rubygems' trusted certificates by the following command:

    gem cert --add aef-gem.pem

Now you can install the gem while automatically verifying it's signature by the
following command:

    gem install bit_set -P HighSecurity

Please notice that you may need other keys for dependent libraries, so you may
have to install dependencies manually.

   [gemkey]: https://aef.name/crypto/aef-gem.pem

### Normal

    gem install bit_set

### Automated testing

Go into the root directory of the installed gem and run the following command
to fetch all development dependencies:

    bundle

Afterwards start the test runner:

    rake spec

If something goes wrong you should be noticed through failing examples.

Development
-----------

### Bug reports and feature requests

Please use the [issue tracker][issues] on github.com to let me know about errors
or ideas for improvement of this software.

   [issues]: https://github.com/god_object/bit_set/issues/

### Source code

This software is developed in the source code management system Git. There are
several synchronized mirror repositories available:

* GitHub
    
    URL: https://github.com/godobject/bit_set.git

* Gitorious
    
    URL: https://git.gitorious.org/bit_set/bit_set.git

* BitBucket
    
    URL: https://bitbucket.org/godobject/bit_set.git

You can get the latest source code with the following command, while
exchanging the placeholder for one of the mirror URLs:

    git clone MIRROR_URL

#### Tags

The final commit before each released gem version will be marked by a tag
named like the version with a prefixed lower-case "v", as required by Semantic
Versioning. Every tag will be signed by my [OpenPGP public key][openpgp] which
enables you to verify your copy of the code cryptographically.

   [openpgp]: https://aef.name/crypto/aef-openpgp.asc

Add the key to your GnuPG keyring by the following command:

    gpg --import aef-openpgp.asc

This command will tell you if your code is of integrity and authentic:

    git tag -v [TAG NAME]

### Contribution

Help on making this software better is always very appreciated. If you want
your changes to be included in the official release, please clone my project
on github.com, create a named branch to commit and push your changes into and
send me a pull request afterwards.

Please make sure to write tests for your changes so that I won't break them
when changing other things on the library. Also notice that I can't promise
to include your changes before reviewing them.

The following people were involved in development:

- Alexander E. Fischer
- Andreas Wurm

License
-------

Copyright GodObject Team <dev@godobject.net>, 2012-2013

This file is part of BitSet.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
