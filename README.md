# Decidim::TermCustomizer

**THIS GEM IS CURRENTLY UNDER DEVELOPMENT, DO NOT USE YET IN PRODUCTION**

[![Build Status](https://travis-ci.com/mainio/decidim-module-term_customizer.svg?branch=master)](https://travis-ci.com/mainio/decidim-module-term_customizer)
[![codecov](https://codecov.io/gh/mainio/decidim-module-term_customizer/branch/master/graph/badge.svg)](https://codecov.io/gh/mainio/decidim-module-term_customizer)

The gem has been developed by [Mainio Tech](https://www.mainiotech.fi/).

A [Decidim](https://github.com/decidim/decidim) module to customize the
localized terms in the system. The module allows administrators to add
"translation sets" through the admin panel which contain customized terms for
any module in the system. These sets can be applied against different scopes
within the system, e.g. the whole system, participatory space scope (e.g. all
participatory processes or a specific participatory process) or a specific
component within a participatory space.

The term customizations will be only applied to the scope which the admin user
has defined for the set. Multiple scopes can be defined against a single
translation set.

Example use cases for this module:

- Admin wants to change the term "Proposal" to "Idea" in all participatory
  processes within the system.
- Admin wants to change the terms "accepted" and "rejected" in the proposals
  component to "possible" and "not possible" for a specific participatory
  process.
- Admin wants to change the term "debate" to "discussion" for all assemblies
  within the system.

Currently using this gem requires a bit of technical knowledge in defining the
terms to be customized. The admin needs to know or find out the translation keys
for the terms to be customized.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-term_customizer", git: "https://github.com/mainio/decidim-module-term_customizer.git"
```

And then execute:

```bash
$ bundle
$ bundle exec rails decidim_term_customizer:install:migrations
$ bundle exec rails db:migrate
```

To keep the gem up to date, you can use the commands above to also update it.

## Usage

- Install the gem.
- Login to the system as an administrator.
- Go to the admin panel > Term customizer.
- Add a new translation set and give it a name (e.g. "All processes"). The
  name of the set is only relevant for the admin to identify what that set is
  used for. It is suggested to give the sets a name that identifies the scope
  where it is used.
- Apply the set to the scope or scopes where you want these customizations to be
  active.
- Save the set.
- Add the translations to the set which you want to customize within the defined
  scope.

## Contributing

For instructions how to setup your development environment for Decidim, see [Decidim](https://github.com/decidim/decidim). Also follow Decidim's general
instructions for development for this project as well.

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
$ npm i
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
$ cd development_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rails s
```

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

The following linters are used:

- Ruby, [Rubocop](https://rubocop.readthedocs.io/)
- JS/ES, [eslint](https://eslint.org/)

You can run the code styling checks by running the following commands from the
console:

```
$ bundle exec rubocop
$ npm run lint
```

To ease up following the style guide, you should install the plugins to your
favorite editor, such as:

- Atom
  * [linter-rubocop](https://atom.io/packages/linter-rubocop)
  * [linter-eslint](https://atom.io/packages/linter-eslint)
- Sublime Text
  * [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
  * [SublimeLinter-eslint](https://github.com/SublimeLinter/SublimeLinter-eslint)
- Visual Studio Code
  * [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)
  * [VS Code ESLint extension](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)

### Testing

To run the tests run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

#### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-term-customizer

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
