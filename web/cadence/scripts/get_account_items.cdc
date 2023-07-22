import NonFungibleToken from 0xNonFungibleToken
import FlowZips from 0xFlowZips

pub fun main(address: Address): [UInt64] {
  if let collection = getAccount(address).getCapability<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic}>(FlowZips.CollectionPublicPath).borrow() {
    return collection.getIDs()
  }

  return []
}