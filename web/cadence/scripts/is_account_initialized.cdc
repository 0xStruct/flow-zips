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

pub fun main(address: Address): {String: Bool} {
  let ret: {String: Bool} = {}
  ret["KittyItems"] = hasItems(address)
  ret["KittyItemsMarket"] = hasStorefront(address)
  return ret
}