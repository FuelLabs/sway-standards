# SRC-9: Native Asset

The following standard attempts to define the keys of relevant onchain metadata for any [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). Any contract that implements the SRC-9 standard MUST implement the [SRC-7](./src-7-asset-metadata.md) and [SRC-20](./src-20-native-asset.md) standards. This is a living standard where revisions may be made as the ecosystem evolves.

> **NOTE** If data is not needed onchain, it is recommended to use the [SRC-15; Offchain Asset Metadata Standard](./src-15-offchain-asset-metadata.md).

## Motivation

The SRC-9 standard seeks to enable relevant onchain data for assets on the Fuel Network. This data may include images, text, contact, or all of the above. All metadata queries are done through a single function to facilitate cross-contract calls.

## Prior Art

The use of generic metadata for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) is defined in the [SRC-7](./src-7-asset-metadata.md) standard. This standard integrates into the existing [SRC-7](./src-7-asset-metadata.md) standard.

## Specification

The following keys are reserved for the SRC-9 standard. Use of the keys should follow the SRC-9 specification.

All keys SHALL use snake case.

### Quick Links

[Social](#social)
[Contact](#contact)
[External Links](#external-links)
[Resources](#resources)
[Images](#images)
[Video](#video)
[Audio](#audio)
[Media](#media)
[Logos](#logos)
[Attributes](#attributes)
[Global](#global)

### Social

The social prefix SHALL be used for any social media platform and SHALL return usernames.

Any social media metadata keys SHALL follow the following syntax `social:site` where:

- The `social` keyword must be prepended to denote this is a social platform
- The `site` keyword must be the website or platform of the social

#### `social:discord`

The key `social:discord` SHALL return a `String` variant of a username for the Discord platform.

#### `social:facebook`

The key `social:facebook` SHALL return a `String` variant of a username for the Facebook platform.

#### `social:farcaster`

The key `social:farcaster` SHALL return a `String` variant of a username for the Farcaster platform.

#### `social:friend.tech`

The key `social:friend.tech` SHALL return a `String` variant of a username for the Friend.tech platform.

#### `social:github`

The key `social:github` SHALL return a `String` variant of a username for the Github platform.

#### `social:instagram`

The key `social:instagram` SHALL return a `String` variant of a username for the Instagram platform.

#### `social:lens`

The key `social:lens` SHALL return a `String` variant of a username for the Lens Protocol.

#### `social:linkedin`

The key `social:linkedin` SHALL return a `String` variant of a username for the LinkedIn platform.

#### `social:reddit`

The key `social:reddit` SHALL return a `String` variant of a username for the Reddit platform.

#### `social:signal`

The key `social:signal` SHALL return a `String` variant of a username for the Signal platform.

#### `social:telegram`

The key `social:telegram` SHALL return a `String` variant of a username for the Telegram platform.

#### `social:tiktok`

The key `social:tiktok` SHALL return a `String` variant of a username for the TikTok platform.

#### `social:x`

The key `social:x` SHALL return a `String` variant of a username for the X or formerly Twitter platform.

#### `social:wechat`

The key `social:wechat` SHALL return a `String` variant of a username for the WeChat platform.

#### `social:whatsapp`

The key `social:whatsapp` SHALL return a `String` variant of a username for the WhatsApp platform.

#### `social:youtube`

The key `social:youtube` SHALL return a `String` variant of a username for the YouTube platform.

### Contact

The `contact` prefix SHALL be used for any contact information on a particular project's team for an asset.

Any contact information metadata keys SHALL follow the following syntax `contract:type` where:

- The `contact` keyword must be prepended to denote this is contact information
- The `type` keyword must be the method of contact

The key SHALL use snake case.

#### `contact:email`

The key `contact:email` SHALL return a `String` variant of an email.

#### `contact:mailing`

The key `contact:mailing` SHALL return a `String` variant of a mailing address. All mailing addresses MUST follow the UPU addressing format.

#### `contact:phone`

The key `contact:phone` SHALL return a `String` variant of a phone number. All phone numbers SHALL follow the E.164 standard.

#### `contact:company`

The key `contact:company` SHALL return a `String` variant of a company name.

### External Links

The `link` prefix SHALL be used for any external webpage hyperlink associated with an asset.

Any external webpage metadata keys SHALL follow the following syntax `link:site` where:

- The `link` keyword must be prepended to denote this is an external webpage
- The `site` keyword must be an external website

#### `link:home`

The key `link:home` SHALL return a `String` variant of the asset's project homepage.

#### `link:contact`

The key `link:contact` SHALL return a `String` variant of the asset's project contact information webpage.

#### `link:docs`

The key `link:docs` SHALL return a `String` variant of the asset's project documentation webpage.

#### `link:forum`

The key `link:forum` SHALL return a `String` variant of the asset's project forum webpage.

#### `link:blog`

The key `link:blog` SHALL return a `String` variant of the asset's project blog.

#### `link:linktree`

The key `link:linktree` SHALL return a `String` variant of the asset's project linktree information webpage.

### Resources

The `res` prefix SHALL be used for any resources or general information on an asset.

Any resource metadata keys SHALL follow the following syntax `rec:type` where:

- The `res` keyword must be prepended to denote this is a resource
- The `type` keyword must be the type of resource

#### `res:license`

The key `res:license` SHALL return a `String` variant of the asset's project license.

#### `res:tos`

The key `res:tos` SHALL return a `String` variant of the asset's project Terms of Service.

#### `res:author`

The key `res:author` SHALL return a `String` variant of the asset's project author. This MAY be a full name or pseudonym.

#### `res:about`

The key `res:about` SHALL return a `String` variant about the asset's project up to 2048 characters.

#### `res:description`

The key `res:description` SHALL return a `String` variant describing the asset's project up to 256 characters.

#### `res:date`

The key `res:date` SHALL return a `Int` variant of a UNIX timestamp.

#### `res:block`

The key `res:block` SHALL return a `Int` variant of a block number.

### Images

The `image` prefix SHALL be used for any image files associated with a singular asset.

Any image metadata keys SHALL follow the following syntax `image:type` where:

- The `image` keyword must be prepended to denote this is an image
- The `type` keyword must be the file type of the image

> **NOTE** If using an ifps hash to store an image offchain, it is recommended to use the [SRC-15; Offchain Asset Metadata Standard](./src-15-offchain-asset-metadata.md).

#### `image:svg`

The key `image:svg` SHALL return a `String` variant of an SVG image.

#### `image:png`

The key `image:png` SHALL return a `String` variant of a URI for a PNG image.

#### `image:jpeg`

The key `image:jpeg` SHALL return a `String` variant of a URI for a JPEG image.

#### `image:webp`

The key `image:webp` SHALL return a `String` variant of a URI for a WebP image.

#### `image:gif`

The key `image:gif` SHALL return a `String` variant of a URI for a GIF image.

#### `image:heif`

The key `image:heif` SHALL return a `String` variant of a URI for a HEIF image.

### Video

The `video` prefix SHALL be used for any video files associated with a singular asset.

Any video metadata keys SHALL follow the following syntax `video:type` where:

- The `video` keyword must be prepended to denote this is a video
- The `type` keyword must be the file type of the video

> **NOTE** If using an ifps hash to store a video offchain, it is recommended to use the [SRC-15; Offchain Asset Metadata Standard](./src-15-offchain-asset-metadata.md).

#### `video:mp4`

The key `video:mp4` SHALL return a `String` variant of a URI for an MP4 video.

#### `video:webm`

The key `video:webm` SHALL return a `String` variant of a URI for a WebM video.

#### `video:m4v`

The key `video:m4v` SHALL return a `String` variant of a URI for a M4V video.

#### `video:ogv`

The key `video:ogv` SHALL return a `String` variant of a URI for an OGV video.

#### `video:ogg`

The key `video:ogg` SHALL return a `String` variant of a URI for an OGG video.

### Audio

The `audio` prefix SHALL be used for any audio files associated with a singular asset.

Any audio metadata keys SHALL follow the following syntax `audio:type` where:

- The `audio` keyword must be prepended to denote this is audio metadata
- The `type` keyword must be the file type of the audio

> **NOTE** If using an ifps hash to store audio offchain, it is recommended to use the [SRC-15; Offchain Asset Metadata Standard](./src-15-offchain-asset-metadata.md).

#### `audio:mp3`

The key `audio:mp3` SHALL return a `String` variant of a URI for an MP3 file.

#### `audio:wav`

The key `audio:wav` SHALL return a `String` variant of a URI for a WAV file.

#### `audio:oga`

The key `audio:oga` SHALL return a `String` variant of a URI for an OGA file.

### Media

The `media` prefix SHALL be used for any media associated with a particular singular asset.

Any media metadata keys SHALL follow the following syntax `media:type` where:

- The `media` keyword must be prepended to denote this is a video
- The `type` keyword must be the file type of the media

> **NOTE** If using an ifps hash to store media offchain, it is recommended to use the [SRC-15; Offchain Asset Metadata Standard](./src-15-offchain-asset-metadata.md).

#### `media:gltf`

The key `media:gltf` SHALL return a `String` variant of a URI for a glTF file.

#### `media:glb`

The key `media:glb` SHALL return a `String` variant of a URI for a GLB file.

### Logos

The `logo` prefix SHALL be used for any images associated with a particular asset or project.

Any logo metadata keys SHALL follow the following syntax `logo:type` where:

- The `logo` keyword must be prepended to denote this is a logo
- The `type` keyword must be the type of logo

#### `logo:svg`

The key `logo:svg` SHALL return a `String` variant of an SVG image of a logo.

#### `logo:svg_light`

The key `logo:svg_light` SHALL return a `String` variant of an SVG image of a logo for light themes.

#### `logo:svg_dark`

The key `logo:svg_dark` SHALL return a `String` variant of an SVG image of a logo for dark themes.

#### `logo:small_light`

The key `logo:small_light` SHALL return a `String` variant of a URI for a 32x32 PNG image of a logo for light themes.

#### `logo:small_dark`

The key `logo:small_dark` SHALL return a `String` variant of a URI for a 32x32 PNG image of a logo for dark themes.

#### `logo:medium_light`

The key `logo:medium_light` SHALL return a `String` variant of a URI for a 256x256 PNG image of a logo for light themes.

#### `logo:medium_dark`

The key `logo:medium_dark` SHALL return a `String` variant of a URI for a 256x256 PNG image of a logo for dark themes.

#### `logo:large_light`

The key `logo:large_light` SHALL return a `String` variant of a URI for a 1024x1024 PNG image of a logo for light themes.

#### `logo:large_dark`

The key `logo:large_dark` SHALL return a `String` variant of a URI for a 1024x1024 PNG image of a logo for dark themes.

### Attributes

The `attr` prefix SHALL be used for any attributes associated with a singular asset.

Any attribute metadata keys SHALL follow the following syntax `attr:type` where:

- The `attr` keyword must be prepended to denote this is an attribute
- The `type` keyword must be the type of attribute

There are no standardized types of attributes.
Example: `attr:eyes`.

### Global

The `global` prefix SHALL be used for any attributes associated with ALL assets minted by a contract.

Any global metadata keys SHALL follow the following syntax `global:key` where:

- The `global` keyword must be prepended to denote this is a global metadata
- The `key` keyword must be the type of metadata using a SRC-9 key defined above

Example: `global:image:png`.

## Rationale

The SRC-9 standard should allow for standardized keys for metadata on the Fuel Network. This standard builds off existing standards and should allow other contracts to query any relevant information on the asset.

## Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets), the [SRC-20](./src-20-native-asset.md) standard, and the [SRC-7](./src-7-asset-metadata.md) standard.

## Security Considerations

This standard does not call external contracts, nor does it define any mutations of the contract state.

## Example

```sway
impl SRC7 for Contract {
    fn metadata(asset: AssetId, key: String) -> Option<Metadata> {
        if (asset != AssetId::default()) {
            return Option::None;
        }

        match key {
            String::from_ascii_str("social:x") => {
                let social = String::from_ascii_str("fuel_network");
                Option::Some(Metadata::String(social))
            },
            _ => Option::None,
        }
    }
}
```
