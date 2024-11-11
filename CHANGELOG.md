# Changelog

## [1.2.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v1.1.0...v1.2.0) (2024-11-11)


### Features

* enhance testing with sequential, parallel modes and flags for exceptions and skip-destroy ([#27](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/27)) ([bb6c120](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/bb6c120bd9b55ab3920fb78d5c8692288e0ef3a3))

## [1.1.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v1.0.0...v1.1.0) (2024-10-11)


### Features

* auto generated docs and refine makefile ([#25](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/25)) ([cbc998d](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/cbc998dd60faf3b57b765090835587da0099109b))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#24](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/24)) ([5c06124](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/5c061246220b440820ad5a3bd58ee4c7544b2edc))

## [1.0.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v0.6.0...v1.0.0) (2024-09-25)


### ⚠ BREAKING CHANGES

* Version 4 of the azurerm provider includes breaking changes.

### Features

* upgrade azurerm provider to v4 ([#22](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/22)) ([89944bf](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/89944bfe2dbaa27a74ac54d614c10a6c722db0b9))

### Upgrade from v0.6.0 to v1.0.0:

- Update module reference to: `version = "~> 1.0"`
- Change properties in vault object:
  - resourcegroup -> resource_group
- Rename variable:
  - resourcegroup -> resource_group

## [0.6.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v0.5.0...v0.6.0) (2024-08-28)


### Features

* update documentation ([#19](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/19)) ([d38ce4b](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/d38ce4b1c5ba712693103887d9759a1d39b6c44e))

## [0.5.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v0.4.0...v0.5.0) (2024-08-28)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#17](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/17)) ([f2881a1](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/f2881a195fd040a08fb4dea156a5d4e46db6d71e))

## [0.4.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v0.3.0...v0.4.0) (2024-07-02)


### Features

* add issue template ([#15](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/15)) ([d7d5b53](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/d7d5b531c00797326da3737fb6e7d1ae118fdff9))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#14](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/14)) ([27ecdf9](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/27ecdf96d39f4292e0468cf3ea25202d951655d0))
* **deps:** bump github.com/hashicorp/go-getter in /tests ([#13](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/13)) ([b321146](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/b3211465bf0d948032576a2612fc43974a40d164))

## [0.3.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v0.2.0...v0.3.0) (2024-06-07)


### Features

* add pull request template ([#11](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/11)) ([7951bf7](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/7951bf7edffe71a92fbc6ef68eeb6520ea73a2cb))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#10](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/10)) ([b5f0493](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/b5f0493f562ea07c058be0d7ae521a2566bd22e0))
* **deps:** bump github.com/hashicorp/go-getter in /tests ([#8](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/8)) ([4026c3d](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/4026c3dd387c0773a5a44685e4bf39a806b49006))
* **deps:** bump golang.org/x/net from 0.17.0 to 0.23.0 in /tests ([#7](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/7)) ([295ddc5](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/295ddc538674c4a6137c823c5046650738039ae6))

## [0.2.0](https://github.com/CloudNationHQ/terraform-azure-rsv/compare/v0.1.0...v0.2.0) (2024-04-10)


### Features

* change defaults classic vmware replication ([#3](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/3)) ([cc5d9b1](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/cc5d9b1e89173c559e259a13b8717464fcb8e814))

## 0.1.0 (2024-04-09)


### Features

* add initial resources ([#1](https://github.com/CloudNationHQ/terraform-azure-rsv/issues/1)) ([00419e2](https://github.com/CloudNationHQ/terraform-azure-rsv/commit/00419e2250a50a0ca1c0248bcc1cefc6951f3fde))
