## [4.1.0](https://github.com/Basis-Theory/basistheory-ios/compare/4.0.2...4.1.0) (2023-12-27)


### Features

* adds custom bin validation ([#69](https://github.com/Basis-Theory/basistheory-ios/issues/69)) ([a54dea5](https://github.com/Basis-Theory/basistheory-ios/commit/a54dea5aac9b00745cd132379c1bce2f4520d6fc))


### [4.0.2](https://github.com/Basis-Theory/basistheory-ios/compare/4.0.1...4.0.2) (2023-12-27)


### Bug Fixes

* allow empty body responses from proxy ([#70](https://github.com/Basis-Theory/basistheory-ios/issues/70)) ([05163a8](https://github.com/Basis-Theory/basistheory-ios/commit/05163a8fd005a2905b1c9234d83da9c6d657f4e0))


### [4.0.1](https://github.com/Basis-Theory/basistheory-ios/compare/4.0.0...4.0.1) (2023-12-12)


### Bug Fixes

* fix card validation being applied before masking ([#68](https://github.com/Basis-Theory/basistheory-ios/issues/68)) ([90c3068](https://github.com/Basis-Theory/basistheory-ios/commit/90c30682a66a2e34013bb0500347662e17406193))


## [4.0.0](https://github.com/Basis-Theory/basistheory-ios/compare/3.0.0...4.0.0) (2023-10-19)


### ⚠ BREAKING CHANGES

* when setting text programmatically on an element, you should now expect a  event and subsequently update of the , ,  and other change flags.

### Bug Fixes

* trigger text change events when setting text programmatically ([#67](https://github.com/Basis-Theory/basistheory-ios/issues/67)) ([7fa76e1](https://github.com/Basis-Theory/basistheory-ios/commit/7fa76e1fe5f5ee0139055627d8e3f8eb54bd5af1))


## [3.0.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.10.1...3.0.0) (2023-09-06)


### ⚠ BREAKING CHANGES

* the value for the month() and year() methods of CardExpirationDateUITextField is now converted to Number before sending to the API to match the APIs 'card' contract instead of String as it was before.

### Features

* add type conversion when submitting element values ([#66](https://github.com/Basis-Theory/basistheory-ios/issues/66)) ([74ee517](https://github.com/Basis-Theory/basistheory-ios/commit/74ee51734e274b72c8d3e2c0536364bedc81980c))


### [2.10.1](https://github.com/Basis-Theory/basistheory-ios/compare/2.10.0...2.10.1) (2023-09-01)


### Bug Fixes

* enable copy icons on card elements ([#65](https://github.com/Basis-Theory/basistheory-ios/issues/65)) ([12d39f6](https://github.com/Basis-Theory/basistheory-ios/commit/12d39f6068f9a27a7ed3e746feb2ac8dec664e11))


## [2.10.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.9.0...2.10.0) (2023-09-01)


### Features

* restores logging ([#64](https://github.com/Basis-Theory/basistheory-ios/issues/64)) ([7a21b64](https://github.com/Basis-Theory/basistheory-ios/commit/7a21b64406004e2aec2db0874e0941d8aafd5e4b))


## [2.9.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.8.0...2.9.0) (2023-09-01)


### Features

* add enableCopy ([#63](https://github.com/Basis-Theory/basistheory-ios/issues/63)) ([2e7e0bf](https://github.com/Basis-Theory/basistheory-ios/commit/2e7e0bff625c0843272b5f8304ce50913a982bff))


## [2.8.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.7.0...2.8.0) (2023-08-29)


### Features

* removes dd ([#62](https://github.com/Basis-Theory/basistheory-ios/issues/62)) ([e58427b](https://github.com/Basis-Theory/basistheory-ios/commit/e58427b87f0349348f038b118fb97af7d94fbcc4))


## [2.7.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.6.0...2.7.0) (2023-08-09)


### Features

* add focus and blur events ([#61](https://github.com/Basis-Theory/basistheory-ios/issues/61)) ([e4d9a18](https://github.com/Basis-Theory/basistheory-ios/commit/e4d9a18454c91ce4cd71f7571a9e0c2d0bb55d28))


## [2.6.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.5.0...2.6.0) (2023-08-08)


### Features

* loose dd version requirement ([#60](https://github.com/Basis-Theory/basistheory-ios/issues/60)) ([e503b53](https://github.com/Basis-Theory/basistheory-ios/commit/e503b53f70ec80238bd4d4d9e8c3f58aef86c67f))


## [2.5.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.4.0...2.5.0) (2023-08-07)


### Features

* lower required iOS version ([#59](https://github.com/Basis-Theory/basistheory-ios/issues/59)) ([b781e96](https://github.com/Basis-Theory/basistheory-ios/commit/b781e967503a36496b29c5c73c339c4c0d54f0bc))


## [2.4.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.3.0...2.4.0) (2023-07-05)


### Features

* adds support for  ([#58](https://github.com/Basis-Theory/basistheory-ios/issues/58)) ([9d6dfc4](https://github.com/Basis-Theory/basistheory-ios/commit/9d6dfc46a5b028eb203df19896f0dd0659fe4b8a))


## [2.3.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.2.0...2.3.0) (2023-06-28)


### Features

* adds extension function to format expiration date ([#56](https://github.com/Basis-Theory/basistheory-ios/issues/56)) ([38c924b](https://github.com/Basis-Theory/basistheory-ios/commit/38c924ba0d80fe7ad1adf3a52f7d567f914040e5))


## [2.2.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.1.0...2.2.0) (2023-06-26)


### Features

* adds http client for sending element values to third parties ([#55](https://github.com/Basis-Theory/basistheory-ios/issues/55)) ([1ba48dd](https://github.com/Basis-Theory/basistheory-ios/commit/1ba48dd7aab94dbebf3c3032f1417e50861fb14f))


## [2.1.0](https://github.com/Basis-Theory/basistheory-ios/compare/2.0.2...2.1.0) (2023-05-29)


### Features

* exposes raw proxy response ([#54](https://github.com/Basis-Theory/basistheory-ios/issues/54)) ([63bb3b8](https://github.com/Basis-Theory/basistheory-ios/commit/63bb3b863428aa0d2a41a1a8965cb514ad5d944e))


### [2.0.2](https://github.com/Basis-Theory/basistheory-ios/compare/2.0.1...2.0.2) (2023-05-11)


### Bug Fixes

* add isComplete calculation to cvc event ([#53](https://github.com/Basis-Theory/basistheory-ios/issues/53)) ([8acc6c4](https://github.com/Basis-Theory/basistheory-ios/commit/8acc6c4366ded26da57f665f1d36dfa5f9448228))


### [2.0.1](https://github.com/Basis-Theory/basistheory-ios/compare/2.0.0...2.0.1) (2023-05-08)


### Bug Fixes

* releasing to CocoaPods ([#52](https://github.com/Basis-Theory/basistheory-ios/issues/52)) ([c18f90c](https://github.com/Basis-Theory/basistheory-ios/commit/c18f90cc2ade32d8d6871f7d862f50c130db3045))


## [2.0.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.12.0...2.0.0) (2023-05-06)


### ⚠ BREAKING CHANGES

* UITextFieldDelegate inheritance on UIViewControllers no longer work with our elements. UIViewControllers must inherit our BasisTheoryUIViewController class for access to UITextFieldDelegate functions

### Features

* adds BasisTheoryUIViewController class ([#51](https://github.com/Basis-Theory/basistheory-ios/issues/51)) ([6866804](https://github.com/Basis-Theory/basistheory-ios/commit/686680478e89f364b5a0c837bc2b0736fb02389d))


## [1.12.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.11.0...1.12.0) (2023-05-03)


### Features

* adds regex validation on text element ([#50](https://github.com/Basis-Theory/basistheory-ios/issues/50)) ([dd26566](https://github.com/Basis-Theory/basistheory-ios/commit/dd26566a31c83d2e5362392ef4026bb223e59a7a))


## [1.11.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.10.0...1.11.0) (2023-03-30)


### Features

* support 8 digit bins ([#49](https://github.com/Basis-Theory/basistheory-ios/issues/49)) ([7181bac](https://github.com/Basis-Theory/basistheory-ios/commit/7181bace7974e7c492be343a3d2c6d23f28af565))


## [1.10.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.9.0...1.10.0) (2023-03-22)


### Features

* allow elements to be passed in proxy body ([4674a5c](https://github.com/Basis-Theory/basistheory-ios/commit/4674a5c557001fa1db0b49b4260c3ea361bd4380))


## [1.9.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.7...1.9.0) (2023-03-14)


### Features

* prevent insertion of months > 12 for card exp date ([#46](https://github.com/Basis-Theory/basistheory-ios/issues/46)) ([8110595](https://github.com/Basis-Theory/basistheory-ios/commit/8110595bcab077ad3e62bde81002d99693b7bd16))


### [1.8.7](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.6...1.8.7) (2023-03-10)


### Bug Fixes

* adds BasisTheoryElements as a part of release commit ([#45](https://github.com/Basis-Theory/basistheory-ios/issues/45)) ([df3581f](https://github.com/Basis-Theory/basistheory-ios/commit/df3581f37650428a7e8cb9b175a38d11000e8b01))


### [1.8.6](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.5...1.8.6) (2023-03-10)


### Bug Fixes

* fixes script to update version number ([#44](https://github.com/Basis-Theory/basistheory-ios/issues/44)) ([eb92f06](https://github.com/Basis-Theory/basistheory-ios/commit/eb92f06a2bd30e43bc4c3dcbf19ad1dfcc6eb34e))


### [1.8.5](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.4...1.8.5) (2023-03-09)


### Bug Fixes

* adds DataDog logging ([#43](https://github.com/Basis-Theory/basistheory-ios/issues/43)) ([b43ce75](https://github.com/Basis-Theory/basistheory-ios/commit/b43ce756bc84d35af39b9dc0b7697cb335e58324))


### [1.8.4](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.3...1.8.4) (2023-02-14)


### Bug Fixes

* adds mask to readonly text element when using setValueRef ([#33](https://github.com/Basis-Theory/basistheory-ios/issues/33)) ([73ef612](https://github.com/Basis-Theory/basistheory-ios/commit/73ef6124e946e32c1a0a043ee2f28f57c993d706))


### [1.8.3](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.2...1.8.3) (2023-02-09)


### Bug Fixes

* fix constant variables on card number ([#38](https://github.com/Basis-Theory/basistheory-ios/issues/38)) ([557d195](https://github.com/Basis-Theory/basistheory-ios/commit/557d1954c77c9410f07fa0fa25d3faa4299f87b8))


### [1.8.2](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.1...1.8.2) (2023-01-31)


### Bug Fixes

* bump swift SDK version ([#37](https://github.com/Basis-Theory/basistheory-ios/issues/37)) ([9ee11ce](https://github.com/Basis-Theory/basistheory-ios/commit/9ee11cead66b84324a678ffa61e4926c88e415e5))


### [1.8.1](https://github.com/Basis-Theory/basistheory-ios/compare/1.8.0...1.8.1) (2023-01-24)


### Bug Fixes

* fixes complete flag on card number element ([#35](https://github.com/Basis-Theory/basistheory-ios/issues/35)) ([f072a3f](https://github.com/Basis-Theory/basistheory-ios/commit/f072a3fa950df34c415ca7535f307b358c6ce0eb))


## [1.8.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.7.0...1.8.0) (2023-01-20)


### Features

* adds getTokenById func ([#34](https://github.com/Basis-Theory/basistheory-ios/issues/34)) ([f82bfd6](https://github.com/Basis-Theory/basistheory-ios/commit/f82bfd60cb6d252847b6863b4842b23992630b47))


## [1.7.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.6.0...1.7.0) (2023-01-11)


### Features

* add metadata and cardElementMetadata variables ([#32](https://github.com/Basis-Theory/basistheory-ios/issues/32)) ([ed35a04](https://github.com/Basis-Theory/basistheory-ios/commit/ed35a04c209ffc2e2fd21376842546340352a3a1))


## [1.6.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.5.0...1.6.0) (2023-01-11)


### Features

* adds createSession service function ([#31](https://github.com/Basis-Theory/basistheory-ios/issues/31)) ([d267347](https://github.com/Basis-Theory/basistheory-ios/commit/d2673477be0aefc6c0e1049d543ba940331c00c9))


## [1.5.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.4.0...1.5.0) (2023-01-09)


### Features

* add  flag to  ([#29](https://github.com/Basis-Theory/basistheory-ios/issues/29)) ([aa8a038](https://github.com/Basis-Theory/basistheory-ios/commit/aa8a038e64e9747684aad5b8701ef7859aae8cfb))


## [1.4.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.3.0...1.4.0) (2023-01-06)


### Features

* add setValueRef for mirroring text elements ([#28](https://github.com/Basis-Theory/basistheory-ios/issues/28)) ([5ae7560](https://github.com/Basis-Theory/basistheory-ios/commit/5ae756081b1efad894e33108de7f7b585c0ccd2b))


## [1.3.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.2.0...1.3.0) (2023-01-06)


### Features

* adds maskChange event on CVC, makes complete flag consistent, checks complete flag on tokenize requests ([#27](https://github.com/Basis-Theory/basistheory-ios/issues/27)) ([bbef2fa](https://github.com/Basis-Theory/basistheory-ios/commit/bbef2fa8da4935fa6eb39459b81af505f2e650b9))


## [1.2.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.1.1...1.2.0) (2023-01-05)


### Features

* adds BIN and last4 to textChange events ([#26](https://github.com/Basis-Theory/basistheory-ios/issues/26)) ([f5b1887](https://github.com/Basis-Theory/basistheory-ios/commit/f5b188744ed243a8d95979a6e15ac3012e5f17d9))


### [1.1.1](https://github.com/Basis-Theory/basistheory-ios/compare/1.1.0...1.1.1) (2023-01-05)


### Bug Fixes

* removing application type check on proxy call ([#25](https://github.com/Basis-Theory/basistheory-ios/issues/25)) ([051bdba](https://github.com/Basis-Theory/basistheory-ios/commit/051bdba3a2c652500227b0518460d6bf9245edc6))


## [1.1.0](https://github.com/Basis-Theory/basistheory-ios/compare/1.0.1...1.1.0) (2022-12-29)


### Features

* adds proxy function ([#24](https://github.com/Basis-Theory/basistheory-ios/issues/24)) ([b91c3ce](https://github.com/Basis-Theory/basistheory-ios/commit/b91c3ce998e14f469f00c3eda334a49731f9ada7))


### [1.0.1](https://github.com/Basis-Theory/basistheory-ios/compare/1.0.0...1.0.1) (2022-12-13)


### Bug Fixes

* fixes issue where we fail to retrieve an app by api key ([#20](https://github.com/Basis-Theory/basistheory-ios/issues/20)) ([0dfdff2](https://github.com/Basis-Theory/basistheory-ios/commit/0dfdff2825945803997e721aa3f55c1fb8e73fce))


## [1.0.0](https://github.com/Basis-Theory/basistheory-ios/compare/0.8.0...1.0.0) (2022-12-09)


### ⚠ BREAKING CHANGES

* throw if input is invalid when tokenizing (#18)
* bump version to 1.0.0 (not actually a breaking change)

### Features

* bump to 1.0 ([#19](https://github.com/Basis-Theory/basistheory-ios/issues/19)) ([499a2d6](https://github.com/Basis-Theory/basistheory-ios/commit/499a2d6f82205ddede21d4bd62b20aa9a65396ee))
* throw if input is invalid when tokenizing ([#18](https://github.com/Basis-Theory/basistheory-ios/issues/18)) ([ac5279b](https://github.com/Basis-Theory/basistheory-ios/commit/ac5279b62592d0516bef07d8c489be4e2b48e64e))


## [0.8.0](https://github.com/Basis-Theory/basistheory-ios/compare/0.7.0...0.8.0) (2022-12-08)


### Features

* add masking to cvc element, conform to mask on insert text, add user-agent header ([#17](https://github.com/Basis-Theory/basistheory-ios/issues/17)) ([ad78d1c](https://github.com/Basis-Theory/basistheory-ios/commit/ad78d1c98cda8c972ec5e6f7e7a6c7994ec71a28))


## [0.7.0](https://github.com/Basis-Theory/basistheory-ios/compare/0.6.0...0.7.0) (2022-12-07)


### Features

* add CardNumber element and card brand events ([#15](https://github.com/Basis-Theory/basistheory-ios/issues/15)) ([b614f0d](https://github.com/Basis-Theory/basistheory-ios/commit/b614f0d5da96550fbd2f677092a9e3ca285e9fa9))


## [0.6.0](https://github.com/Basis-Theory/basistheory-ios/compare/0.5.0...0.6.0) (2022-12-02)


### Features

* adds card brand detecting module ([#14](https://github.com/Basis-Theory/basistheory-ios/issues/14)) ([98c5bff](https://github.com/Basis-Theory/basistheory-ios/commit/98c5bff0508e0ce501a8546f7bc7c01eaad22c66))


## [0.5.0](https://github.com/Basis-Theory/basistheory-ios/compare/0.4.0...0.5.0) (2022-12-01)


### Features

* Add transform function for phone numbers ([#8](https://github.com/Basis-Theory/basistheory-ios/issues/8)) ([1e7bf30](https://github.com/Basis-Theory/basistheory-ios/commit/1e7bf3095062561f4c91c34cd251123fdfefa461))


## [0.4.0](https://github.com/Basis-Theory/basistheory-ios/compare/0.3.2...0.4.0) (2022-12-01)


### Features

* add card expiration date element ([#13](https://github.com/Basis-Theory/basistheory-ios/issues/13)) ([f746c1c](https://github.com/Basis-Theory/basistheory-ios/commit/f746c1cff0c63d4e6c49d59953f7c38667d7d330))


### [0.3.2](https://github.com/Basis-Theory/basistheory-ios/compare/0.3.1...0.3.2) (2022-11-29)


### Bug Fixes

* changes source files. releases to CocoaPods ([#12](https://github.com/Basis-Theory/basistheory-ios/issues/12)) ([397a17c](https://github.com/Basis-Theory/basistheory-ios/commit/397a17c34deb1e5436b426a1315cbc23992cf3f0))


### [0.3.1](https://github.com/Basis-Theory/basistheory-ios/compare/0.3.0...0.3.1) (2022-11-28)


### Bug Fixes

* releases to CocoaPods ([#11](https://github.com/Basis-Theory/basistheory-ios/issues/11)) ([fc2491f](https://github.com/Basis-Theory/basistheory-ios/commit/fc2491f5ff539412b402b1030b285e38b8cd3e9d))


## [0.3.0](https://github.com/Basis-Theory/basistheory-ios/compare/0.2.0...0.3.0) (2022-11-28)


### Features

* add input mask to text element ([#9](https://github.com/Basis-Theory/basistheory-ios/issues/9)) ([b64ae90](https://github.com/Basis-Theory/basistheory-ios/commit/b64ae90308235d2890c110c851bc2e9e89551f5e))
* Call POST /tokens with the element data ([#7](https://github.com/Basis-Theory/basistheory-ios/issues/7)) ([779b4ca](https://github.com/Basis-Theory/basistheory-ios/commit/779b4ca88f020001ad4cae617b1b60d153a9f384))


