import NonFungibleToken from 0xNonFungibleToken
import KittyItems from 0xKittyItems

pub fun getOrCreateCollection(account: AuthAccount): &KittyItems.Collection{NonFungibleToken.Receiver} {
  if let collectionRef = account.borrow<&KittyItems.Collection>(from: KittyItems.CollectionStoragePath) {
    return collectionRef
  }

  // create a new empty collection
  let collection <- KittyItems.createEmptyCollection() as! @KittyItems.Collection

  let collectionRef = &collection as &KittyItems.Collection
  
  // save it to the account
  account.save(<-collection, to: KittyItems.CollectionStoragePath)

  // create a public capability for the collection
  account.link<&KittyItems.Collection{NonFungibleToken.CollectionPublic, KittyItems.CollectionPublic}>(KittyItems.CollectionPublicPath, target: KittyItems.CollectionStoragePath)

  return collectionRef
}

transaction(recipient: Address, zipName: String, zipValue: String, color: UInt8) {

  let kittyItemsCollection: &KittyItems.Collection{NonFungibleToken.Receiver}
  let recipientCollectionRef: &{NonFungibleToken.CollectionPublic}

  prepare(signer: AuthAccount) {
    self.kittyItemsCollection = getOrCreateCollection(account: signer)

    // Borrow the recipient's public NFT collection reference
    self.recipientCollectionRef = getAccount(0x179b6b1cb6755e31)
        .getCapability(KittyItems.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not get receiver reference to the NFT Collection")
  }

  execute {
    let kindValue = KittyItems.Kind(rawValue: 1) ?? panic("invalid kind")
    let rarityValue = KittyItems.Rarity(rawValue: color) ?? panic("invalid rarity")

    KittyItems.mintNFT(
        recipient: self.recipientCollectionRef,
        kind: kindValue,
        rarity: rarityValue,
        royalties: [],
        zipName: zipName,
        zipValue: zipValue            
    )
  }
}