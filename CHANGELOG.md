# Changelog

All notable changes to this project will be documented in this file.

## [v1.0.0](https://github.com/Thor77/puppet-sogo/tree/1.0.0) (2020-11-22)

[All commits](https://github.com/Thor77/puppet-sogo/compare/0.3.0...1.0.0)

**Changes:**

* **Breaking change:** Extended templating [\#5](https://github.com/Thor77/puppet-sogo/pull/5) by [@mat1010](https://github.com/mat1010)

Until this change the Puppet `Hash` type was templated as an SOGo config array with the hash as it's only element.
After it, Puppet types are rendered as their correct counterparts.
As the config key `SOGoUserSources` requires an SOGo config array, you probably have to adjust the value provided to the `$config` parameter.

## [v0.3.0](https://github.com/Thor77/puppet-sogo/tree/0.3.0) (2020-10-14)

[All commits](https://github.com/Thor77/puppet-sogo/compare/0.2.0...0.3.0)

**Changes:**

* Add rspec tests [\#2](https://github.com/Thor77/puppet-sogo/pull/2) by [@mat1010](https://github.com/mat1010)
* Add acceptance tests [\#3](https://github.com/Thor77/puppet-sogo/pull/3) by [@mat1010](https://github.com/mat1010)
* Allow array of hashes in sogo.conf [\#4](https://github.com/Thor77/puppet-sogo/pull/4) by [@mat1010](https://github.com/mat1010)
