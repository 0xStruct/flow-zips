import NonFungibleToken from 0xNonFungibleToken
import FlowZips from 0xFlowZips

pub fun getOrCreateCollection(account: AuthAccount): &FlowZips.Collection{NonFungibleToken.Receiver} {
  if let collectionRef = account.borrow<&FlowZips.Collection>(from: FlowZips.CollectionStoragePath) {
    return collectionRef
  }

  // create a new empty collection
  let collection <- FlowZips.createEmptyCollection() as! @FlowZips.Collection

  let collectionRef = &collection as &FlowZips.Collection
  
  // save it to the account
  account.save(<-collection, to: FlowZips.CollectionStoragePath)

  // create a public capability for the collection
  account.link<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic}>(FlowZips.CollectionPublicPath, target: FlowZips.CollectionStoragePath)

  return collectionRef
}

transaction(recipient: Address, zipName: String, zipValue: String, color: UInt8) {

  let flowZipsCollection: &FlowZips.Collection{NonFungibleToken.Receiver}
  let recipientCollectionRef: &{NonFungibleToken.CollectionPublic}

  prepare(signer: AuthAccount) {
    self.flowZipsCollection = getOrCreateCollection(account: signer)

    // Borrow the recipient's public NFT collection reference
    self.recipientCollectionRef = getAccount(signer.address)
        .getCapability(FlowZips.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not get receiver reference to the NFT Collection")
  }

  execute {
    let kindValue = FlowZips.Kind(rawValue: 1) ?? panic("invalid kind")
    let rarityValue = FlowZips.Rarity(rawValue: color) ?? panic("invalid rarity")

    FlowZips.mintNFT(
        recipient: self.recipientCollectionRef,
        kind: kindValue,
        rarity: rarityValue,
        royalties: [],
        zipName: zipName,
        zipValue: zipValue            
    )
  }
}