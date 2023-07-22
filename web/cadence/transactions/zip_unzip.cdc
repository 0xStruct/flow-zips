import NonFungibleToken from 0xNonFungibleToken
import FlowToken from 0xFlowToken
import FlowZips from 0xFlowZips

transaction(id: UInt64) {

  let ownerCollection: &{FlowZips.CollectionOwner}?

  prepare(account: AuthAccount) {

    self.ownerCollection = account.borrow<&{FlowZips.CollectionOwner}>(from: FlowZips.CollectionStoragePath)

  }

  execute {
    self.ownerCollection?.unzipZip(id: id)
  }
}