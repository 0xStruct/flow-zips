import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import FlowZips from "../../contracts/FlowZips.cdc"

// This script returns the size of an account's KittyItems collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(FlowZips.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}
