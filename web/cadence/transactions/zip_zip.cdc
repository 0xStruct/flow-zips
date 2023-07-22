import NonFungibleToken from 0xNonFungibleToken
import FlowToken from 0xFlowToken
import FlowZips from 0xKittyItems

transaction(id: UInt64, zipData: String) {

  //let kittyItemsProvider: Capability<&FlowZips.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>

  let ownerCollection: &{FlowZips.CollectionOwner}?

  prepare(account: AuthAccount) {
 
    self.ownerCollection = account.borrow<&{FlowZips.CollectionOwner}>(from: FlowZips.CollectionStoragePath)

  }

  execute {
    self.ownerCollection?.zipZip(id: id, zipData: zipData)
  }
}