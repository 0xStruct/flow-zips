import NonFungibleToken from 0xNonFungibleToken
import FlowToken from 0xFlowToken
import KittyItems from 0xKittyItems

transaction(id: UInt64) {

  //let kittyItemsProvider: Capability<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>

  let ownerCollection: &{KittyItems.CollectionOwner}?

  prepare(account: AuthAccount) {

    self.ownerCollection = account.borrow<&{KittyItems.CollectionOwner}>(from: KittyItems.CollectionStoragePath)

  }

  execute {
    self.ownerCollection?.unzipZip(id: id)
  }
}