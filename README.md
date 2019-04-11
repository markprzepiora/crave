# Crave [![Build Status](https://travis-ci.org/markprzepiora/crave.svg?branch=master)](https://travis-ci.org/markprzepiora/crave) [![Test Coverage](https://api.codeclimate.com/v1/badges/a3c297ae1abe94ca98f8/test_coverage)](https://codeclimate.com/github/markprzepiora/crave/test_coverage)

**This is a work in progress. Not ready for any kind of real-world use yet!**

Crave is a software dependency manager used to generate per-project development
environment files (for use with [direnv](https://direnv.net/)).

What kinds of dependencies? Any software you need to develop your project!
Right now, that includes:

- Ruby
- PostgreSQL
- Redis

Think of it like `chruby` but for more than only Ruby!

For example, you might define the following file named `Cravefile.rb`:

```
dependency 'ruby', '~> 2.6'
dependency 'postgres', '~> 9.6'
dependency 'redis'
```

Then you would run the `crave` command, which (assuming you have compatible
versions of the listed packages installed) would generate the following
`.envrc` file:

```
# ruby
export RUBY_ENGINE="ruby"
export RUBY_VERSION="2.6.1"
export GEM_ROOT="/home/mark/.rubies/ruby-2.6.1/lib/ruby/gems/2.6.0"
export GEM_HOME="/home/mark/.gem/ruby/2.6.1"
export GEM_PATH="/home/mark/.gem/ruby/2.6.1:/home/mark/.rubies/ruby-2.6.1/lib/ruby/gems/2.6.0"
PATH_add "/home/mark/.gem/ruby/2.6.1/bin"
PATH_add "/home/mark/.rubies/ruby-2.6.1/lib/ruby/gems/2.6.0/bin"
mkdir -p .bin
ln -sf "/home/mark/.rubies/ruby-2.6.1/bin/erb" ".bin/erb"
ln -sf "/home/mark/.rubies/ruby-2.6.1/bin/gem" ".bin/gem"
ln -sf "/home/mark/.rubies/ruby-2.6.1/bin/irb" ".bin/irb"
ln -sf "/home/mark/.rubies/ruby-2.6.1/bin/rake" ".bin/rake"
ln -sf "/home/mark/.rubies/ruby-2.6.1/bin/rdoc" ".bin/rdoc"
ln -sf "/home/mark/.rubies/ruby-2.6.1/bin/ri" ".bin/ri"
ln -sf "/home/mark/.rubies/ruby-2.6.1/bin/ruby" ".bin/ruby"

# postgres
mkdir -p .bin
ln -sf "/usr/lib/postgresql/9.6/bin/createdb" ".bin/createdb"
ln -sf "/usr/lib/postgresql/9.6/bin/createuser" ".bin/createuser"
ln -sf "/usr/lib/postgresql/9.6/bin/dropdb" ".bin/dropdb"
ln -sf "/usr/lib/postgresql/9.6/bin/initdb" ".bin/initdb"
ln -sf "/usr/lib/postgresql/9.6/bin/pg_dump" ".bin/pg_dump"
ln -sf "/usr/lib/postgresql/9.6/bin/pg_restore" ".bin/pg_restore"
ln -sf "/usr/lib/postgresql/9.6/bin/postgres" ".bin/postgres"
ln -sf "/usr/lib/postgresql/9.6/bin/psql" ".bin/psql"

# redis
mkdir -p .bin
ln -sf "/usr/bin/redis-cli" ".bin/redis-cli"
ln -sf "/usr/bin/redis-server" ".bin/redis-server"

# Finally, add the .bin directory to the path
PATH_add .bin
```


# What is the use case that Crave fills?

Setting up development environments without the need to virtual machines,
Docker, or anything like that, from any Unix-like operating system as long as
it supports the software you need!


# What Crave DOES do

- Specifies environment variables, PATHs, and creates symlinks specific
  versions of your dependencies so that they're available within your project.
- It creates a `.envrc` file for use with [direnv](https://direnv.net/) that
  actually sets up all the values listed in the first bullet point.


# What Crave does NOT do

- Install your dependencies for you. In the future, Crave may give you hints
  about what commands to run to install your dependencies, depending on your
  OS. However, for the time being, Crave assumes you will take care of that
  yourself.
- Magically switch what instance of (e.g.) PostgreSQL is running using your
  OS's service system. For example, if you have two versions of PostgreSQL
  installed, this won't make `psql` magically connect to the version of
  PostgreSQL you want.  Instead, the intended use case is for you to set up
  a self-contained instance of PostgreSQL as part of e.g. your development
  `Procfile`.


# Fair Warning

Crave will run executables on your machine!

For example, imagine we're looking for a Ruby installation.

When looking for your Ruby installation, Crave will look for executables in
your PATH and other common installation directories named `ruby*`, and run
those executables with the `--version` flag to check whether they are really a
Ruby installation, and what version of Ruby they are.

Once Crave has found a matching installation of Ruby, it will run that
executable again with some code to generate the values for all the environment
variables you need to switch Ruby versions.

(This process is similar to what, for example, a tool like `chruby` does.)

On normal setups, this is no cause for concern. However, watch out for any
wizards, witches, or trickster demigods who might have put a bash script on
your computer named `ruby` that runs something like `rm -rf /`.
