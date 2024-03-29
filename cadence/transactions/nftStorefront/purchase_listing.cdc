import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import FlowToken from "../../contracts/FlowToken.cdc"
import FlowZips from "../../contracts/FlowZips.cdc"
import NFTStorefrontV2 from "../../contracts/NFTStorefrontV2.cdc"

pub fun getOrCreateCollection(account: AuthAccount): &FlowZips.Collection{NonFungibleToken.Receiver} {
    if let collectionRef = account.borrow<&FlowZips.Collection>(from: FlowZips.CollectionStoragePath) {
        return collectionRef
    }

    // create a new empty collection
    let collection <- FlowZips.createEmptyCollection() as! @FlowZips.Collection

    let collectionRef = &collection as &FlowZips.Collection
    
    // save it to the account
    account.save(<-collection, to: FlowZips.CollectionStoragePath)

    // create a public capability for the collection
    account.link<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic}>(FlowZips.CollectionPublicPath, target: FlowZips.CollectionStoragePath)

    return collectionRef
}

transaction(listingResourceID: UInt64, storefrontAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let kittyItemsCollection: &FlowZips.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}
    let listing: &NFTStorefrontV2.Listing{NFTStorefrontV2.ListingPublic}

    prepare(account: AuthAccount) {
        // Access the storefront public resource of the seller to purchase the listing.
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(
                NFTStorefrontV2.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        // Borrow the listing
        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
                    ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        // Access the vault of the buyer to pay the sale price of the listing.
        let mainFlowVault = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from account storage")
        self.paymentVault <- mainFlowVault.withdraw(amount: price)

        self.kittyItemsCollection = getOrCreateCollection(account: account)
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault,
            commissionRecipient: nil
        )

        self.kittyItemsCollection.deposit(token: <-item)
        self.storefront.cleanupPurchasedListings(listingResourceID: listingResourceID)
    }
}
