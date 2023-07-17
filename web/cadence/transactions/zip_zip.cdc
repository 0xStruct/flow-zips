import NonFungibleToken from 0xNonFungibleToken
import FlowToken from 0xFlowToken
import KittyItems from 0xKittyItems

transaction(id: UInt64, zipData: String) {

  //let kittyItemsProvider: Capability<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>

  let ownerCollection: &{KittyItems.CollectionOwner}?

  prepare(account: AuthAccount) {
    // We need a provider capability, but one is not provided by default so we create one if needed.
    /*let kittyItemsCollectionProviderPrivatePath = /private/kittyItemsCollectionProviderV14

    if !account.getCapability<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(kittyItemsCollectionProviderPrivatePath)!.check() {
      account.link<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(kittyItemsCollectionProviderPrivatePath, target: KittyItems.CollectionStoragePath)
    }

    self.kittyItemsProvider = account.getCapability<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(kittyItemsCollectionProviderPrivatePath)!

    assert(self.kittyItemsProvider.borrow() != nil, message: "Missing or mis-typed KittyItems.Collection provider")
    */

    self.ownerCollection = account.borrow<&{KittyItems.CollectionOwner}>(from: KittyItems.CollectionStoragePath)

  }

  execute {
    self.ownerCollection?.zipZip(id: id, zipData: zipData)
  }
}