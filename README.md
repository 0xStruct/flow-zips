**DEMO VIDEO:** https://vimeo.com/846063742

**DEMO APP:** https://flow-zips.vercel.app

This project implements zips (which keep secrets in decentralized trustless manner) into FLOW NFTs.
The codebase build upon typical FLOW NFT project, Kitty Items, to add zips into NFTs.

![https://imgur.com/J1lj6OS](https://i.imgur.com/J1lj6OS.png)

Trustless secret management is done through LIT Protocol (https://litprotocol.com)

### Trustless encryption and decryption flow

- Owner encrypts secret via Lit with specified access conditions
	- Owner gets by encrypted secret and encrypted symmetric key

- Lit doesn’t have full key, only distributed partial keys on various nodes

- Owner proves ownership of the NFT Zip
	- Lit verifies by checking last redeem timestamp (which only owner can set)
	- Then owner get back decrypted symmetric key to decrypt the secret
	- NFT Zip on FLOW is marked as “unzipped” forever

_Throughout the process, FLOW Zips don't get in the way of secrets_

### Code Walkthrough

Both NFT resource and Collection resource have `Owner` and `Public` interfaces
```
    pub resource interface NFTPublic {
        pub let id: UInt64
        pub fun getZip(): Zip
    }
```
```
    pub resource interface NFTOwner {
        pub let id: UInt64
        pub fun zipZip(_ zipData: String)
        pub fun unzipZip()
    }
```

Certain NFT fields are set to `access(self)`
```
    access(self) var zipStatus: String
    access(self) var zipData: String
    ...
```

As LIT doesn't support FLOW blockchain yet, below walkaround is implemented.
- Lit access control condition [ACC](https://gist.github.com/0xStruct/01eac9bec2d926309d9f997949695227#file-accessconditions-js) is set for each zip at encryption time
- Lit Action [Code](https://gist.github.com/0xStruct/01eac9bec2d926309d9f997949695227#file-litactioncode-js) runs on distributed Lit nodes to query NFT's zipLastUzipTime and zipStatus
	- via FLOW REST API by calling a [Cadence script](https://gist.github.com/0xStruct/01eac9bec2d926309d9f997949695227#file-checkzipunzip-cdc)
- As zipStatus can be set to _unzipped_ only by the owner, only owner can prove the condition and get back the decrypted symmetric key



