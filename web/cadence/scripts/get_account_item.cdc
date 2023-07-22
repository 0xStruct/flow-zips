import NonFungibleToken from 0xNonFungibleToken
import MetadataViews from 0xMetadataViews
import FlowZips from 0xFlowZips

pub struct FlowZip {
  pub let name: String
  pub let description: String
  pub let image: String

  pub let itemID: UInt64
  pub let resourceID: UInt64
  pub let kind: FlowZips.Kind
  pub let rarity: FlowZips.Rarity
  pub let owner: Address

  pub let zipStatus: String
  pub let zipData: String
  pub let zipValue: String
  pub let zipName: String
  pub let zipLastUnzipTime: UFix64?

  init(
    name: String,
    description: String,
    image: String,
    itemID: UInt64,
    resourceID: UInt64,
    kind: FlowZips.Kind,
    rarity: FlowZips.Rarity,
    owner: Address,
    zipStatus: String,
    zipData: String,
    zipValue: String,
    zipName: String,
    zipLastUnzipTime: UFix64?
  ) {
    self.name = name
    self.description = description
    self.image = image

    self.itemID = itemID
    self.resourceID = resourceID
    self.kind = kind
    self.rarity = rarity
    self.owner = owner

    self.zipStatus = zipStatus
    self.zipData = zipData
    self.zipValue = zipValue
    self.zipName = zipName
    self.zipLastUnzipTime = zipLastUnzipTime
  }
}

pub fun fetch(address: Address, itemID: UInt64): FlowZip? {
  if let collection = getAccount(address).getCapability<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic}>(FlowZips.CollectionPublicPath).borrow() {

    let ref = collection.borrowNFTPublic(id: itemID)
    let zip = ref?.getZip() 
    log(zip)

    if let item = collection.borrowFlowZip(id: itemID) {

      if let view = item.resolveView(Type<MetadataViews.Display>()) {

        let display = view as! MetadataViews.Display

        let owner: Address = item.owner!.address!

        let ipfsThumbnail = display.thumbnail as! MetadataViews.IPFSFile

        return FlowZip(
          name: display.name,
          description: display.description,
          image: item.imageCID(),
          itemID: itemID,
          resourceID: item.uuid,
          kind: item.kind,
          rarity: item.rarity,
          owner: address,
          zipStatus: zip?.zipStatus!,
          zipData: zip?.zipData!,
          zipValue: zip?.zipValue!,
          zipName: zip?.zipName!,
          zipLastUnzipTime: zip?.zipLastUnzipTime,
        )
      }
    }
  }

  return nil
}

pub fun main(keys: [String], addresses: [Address], ids: [UInt64]): {String: FlowZip?} {
  let r: {String: FlowZip?} = {}
  var i = 0
  while i < keys.length {
    let key = keys[i]
    let address = addresses[i]
    let id = ids[i]
    r[key] = fetch(address: address, itemID: id)
    i = i + 1
  }
  return r
}