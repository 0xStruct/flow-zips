import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken
import FlowZips from 0xFlowZips
import NFTStorefrontV2 from 0xNFTStorefront

pub fun hasItems(_ address: Address): Bool {
  return getAccount(address)
    .getCapability<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic}>(FlowZips.CollectionPublicPath)
    .check()
}

pub fun hasStorefront(_ address: Address): Bool {
  return getAccount(address)
    .getCapability<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(NFTStorefrontV2.StorefrontPublicPath)
    .check()
}

transaction {
  prepare(acct: AuthAccount) {
    if !hasItems(acct.address) {
      if acct.borrow<&FlowZips.Collection>(from: FlowZips.CollectionStoragePath) == nil {
        acct.save(<-FlowZips.createEmptyCollection(), to: FlowZips.CollectionStoragePath)
      }

      acct.unlink(FlowZips.CollectionPublicPath)

      acct.link<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic}>(FlowZips.CollectionPublicPath, target: FlowZips.CollectionStoragePath)
    }

    if !hasStorefront(acct.address) {
      if acct.borrow<&NFTStorefrontV2.Storefront>(from: NFTStorefrontV2.StorefrontStoragePath) == nil {
        acct.save(<-NFTStorefrontV2.createStorefront(), to: NFTStorefrontV2.StorefrontStoragePath)
      }

      acct.unlink(NFTStorefrontV2.StorefrontPublicPath)
      
      acct.link<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(NFTStorefrontV2.StorefrontPublicPath, target: NFTStorefrontV2.StorefrontStoragePath)
    }
  }
}