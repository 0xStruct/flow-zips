**DEMO VIDEO:** https://vimeo.com/846063742

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

Certain NFT fields are set to `access(self)`

As LIT doesn't support FLOW blockchain yet, below walkaround is implemented.

- Lit Action runs on distributed Lit nodes to query NFT's lastUzipTimestamp and zipStatus via FLOW REST API
- As these are only accessible by the owner, only owner can prove the condition and get back the decrypted symmetric key



