**DEMO VIDEO:** https://vimeo.com/846063742

This project implements zips (which keep secrets in decentralized trustless manner) into FLOW NFTs.
The codebase build upon typical FLOW NFT project, Kitty Items, to add zips into NFTs.

Trustless secret management is done through LIT Protocol (https://litprotocol.com)

**Trustless encryption and decryption flow is like below:**

- Owner encrypts secret via Lit with specified access conditions
	- Owner gets by encrypted secrets and encrypted symmetric key

- Lit doesn’t have full key, only distributed partial keys on various nodes

- Owner proves ownership of the NFT Zip
	- Lit verifies
	- Then owner get decrypted secret back
	- NFT Zip on FLOW is marked as “unzipped” forever

_Throughout the process, FLOW Zips don't get in the way of secrets_

**Explanation on code will be added below:**
