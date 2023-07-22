import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import FlowZips from "../../contracts/FlowZips.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

// This transaction configures an account to hold Kitty Items.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&FlowZips.Collection>(from: FlowZips.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- FlowZips.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: FlowZips.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic, MetadataViews.ResolverCollection}>(FlowZips.CollectionPublicPath, target: FlowZips.CollectionStoragePath)
        }
        
    }
}
