import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub contract FlowZips: NonFungibleToken {

    // totalSupply
    // The total number of FlowZips that have been minted
    //
    pub var totalSupply: UInt64

    // keep track of holders to get a zip by id
    access(account) var holders: {UInt64 : Address}

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, kind: UInt8, rarity: UInt8)
    pub event ImagesAddedForNewKind(kind: UInt8)

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub enum Rarity: UInt8 {
        pub case blue
        pub case green
        pub case purple
        pub case gold
    }

    pub fun rarityToString(_ rarity: Rarity): String {
        switch rarity {
            case Rarity.blue:
                return "Blue"
            case Rarity.green:
                return "Green"
            case Rarity.purple:
                return "Purple"
            case Rarity.gold:
                return "Gold"
        }

        return ""
    }

    pub enum Kind: UInt8 {
        pub case fishbowl
        pub case fishhat
        pub case milkshake
        pub case tuktuk
        pub case skateboard
    }

    pub fun kindToString(_ kind: Kind): String {
        switch kind {
            case Kind.fishbowl:
                return "Fishbowl"
            case Kind.fishhat:
                return "Fish Hat"
            case Kind.milkshake:
                return "Milkshake"
            case Kind.tuktuk:
                return "Tuk-Tuk"
            case Kind.skateboard:
                return "Skateboard"
        }

        return ""
    }

    // Zip struct for reading only
    pub struct Zip {
        pub let zipStatus: String
        pub let zipData: String
        pub let zipValue: String?
        pub let zipName: String?
        pub let zipLastUnzipTime: UFix64?

        init(
            zipStatus: String,
            zipData: String,
            zipValue: String?,
            zipName: String?,
            zipLastUnzipTime: UFix64?
        ) {
            self.zipStatus = zipStatus
            self.zipData = zipData
            self.zipValue = zipValue
            self.zipName = zipName
            self.zipLastUnzipTime = zipLastUnzipTime
        }
    }
    // Mapping from item (kind, rarity) -> IPFS image CID
    //
    access(self) var images: {Kind: {Rarity: String}}

    // Mapping from rarity -> price
    //
    access(self) var itemRarityPriceMap: {Rarity: UFix64}

    // Return the initial sale price for an item of this rarity.
    //
    pub fun getItemPrice(rarity: Rarity): UFix64 {
        return self.itemRarityPriceMap[rarity]!
    }

    pub fun getZipHolder(id: UInt64): Address {
        return self.holders[id]!
    }

    pub resource interface NFTPublic {
        pub let id: UInt64
        pub fun getZip(): Zip
    }

    pub resource interface NFTOwner {
        pub let id: UInt64
        pub fun zipZip(_ zipData: String)
        pub fun unzipZip()
    }

    // A Kitty Item as an NFT
    //
    pub resource NFT: NFTOwner, NFTPublic, NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64

        pub fun name(): String {
            return FlowZips.rarityToString(self.rarity)
                .concat(" ")
                .concat(FlowZips.kindToString(self.kind))
        }
        
        pub fun description(): String {
            return "A "
                .concat(FlowZips.rarityToString(self.rarity).toLower())
                .concat(" ")
                .concat(FlowZips.kindToString(self.kind).toLower())
                .concat(" with serial number ")
                .concat(self.id.toString())
        }

        pub fun imageCID(): String {
            return FlowZips.images[self.kind]![self.rarity]!
        }

        pub fun thumbnail(): MetadataViews.IPFSFile {
          return MetadataViews.IPFSFile(cid: self.imageCID(), path: "sm.png")
        }

        access(self) let royalties: [MetadataViews.Royalty]
        access(self) let metadata: {String: AnyStruct}

        access(self) var zipStatus: String
        access(self) var zipData: String
        access(self) var zipValue: String?
        access(self) var zipName: String?
        // this is to limit open time window for unizip request
        access(self) var zipLastUnzipTime: UFix64?

        // The token kind (e.g. Fishbowl)
        pub let kind: Kind

        // The token rarity (e.g. Gold)
        pub let rarity: Rarity

        init(
            id: UInt64,
            royalties: [MetadataViews.Royalty],
            metadata: {String: AnyStruct},
            kind: Kind, 
            rarity: Rarity,  
        ){
            self.id = id
            self.royalties = royalties
            self.metadata = metadata

            self.kind = kind
            self.rarity = rarity

            self.zipStatus = "blank"
            self.zipData = ""
            self.zipValue = self.metadata["zipValue"]! as! String
            self.zipName = self.metadata["zipName"]! as! String
            self.zipLastUnzipTime = nil
        }

        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name(),
                        description: self.description(),
                        thumbnail: self.thumbnail()
                    )
                case Type<MetadataViews.Editions>():
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: "FlowZips NFT Edition", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        self.royalties
                    )
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://kitty-items.flow.com/".concat(self.id.toString()))
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: FlowZips.CollectionStoragePath,
                        publicPath: FlowZips.CollectionPublicPath,
                        providerPath: /private/FlowZipsCollection,
                        publicCollection: Type<&FlowZips.Collection{FlowZips.CollectionPublic}>(),
                        publicLinkedType: Type<&FlowZips.Collection{FlowZips.CollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&FlowZips.Collection{FlowZips.CollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                            return <-FlowZips.createEmptyCollection()
                        })
                    )
                case Type<MetadataViews.NFTCollectionDisplay>():
                    let media = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                        ),
                        mediaType: "image/svg+xml"
                    )
                    return MetadataViews.NFTCollectionDisplay(
                        name: "The FlowZips Collection",
                        description: "This collection is used as an example to help you develop your next Flow NFT.",
                        externalURL: MetadataViews.ExternalURL("https://kitty-items.flow.com/"),
                        squareImage: media,
                        bannerImage: media,
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/flow_blockchain")
                        }
                    )
                case Type<MetadataViews.Traits>():
                    // exclude mintedTime and foo to show other uses of Traits
                    let excludedTraits = ["mintedTime", "foo"]
                    let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)

                    // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
                    let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                    traitsView.addTrait(mintedTimeTrait)

                    // foo is a trait with its own rarity
                    let fooTraitRarity = MetadataViews.Rarity(score: 10.0, max: 100.0, description: "Common")
                    let fooTrait = MetadataViews.Trait(name: "foo", value: self.metadata["foo"], displayType: nil, rarity: fooTraitRarity)
                    traitsView.addTrait(fooTrait)
                    
                    return traitsView

            }
            return nil    
        }

        // NFTPublic - public can just view
        pub fun getZip(): Zip {
            return Zip(
                zipStatus: self.zipStatus,
                zipData: self.zipData, 
                zipValue: self.zipValue,
                zipName: self.zipName,
                zipLastUnzipTime: self.zipLastUnzipTime
            )
        }

        // NFTOwner - only owner of the item can access
        pub fun zipZip(_ zipData: String) {
            // check that zipStatus == "empty"
            
            self.zipStatus = "zipped"
            self.zipData = zipData
        }
        pub fun unzipZip() {
            // check that zipStatus == "zipped" || "unzipped"
            
            self.zipStatus = "unzipped"

            let currentBlock = getCurrentBlock()
            self.zipLastUnzipTime = currentBlock.timestamp
        }
    }

    // This is the interface that users can cast their FlowZips Collection as
    // to allow others to deposit FlowZips into their Collection. It also allows for reading
    // the details of FlowZips in the Collection.
    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowFlowZip(id: UInt64): &FlowZips.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow FlowZip reference: The ID of the returned reference is incorrect"
            }
        }
        pub fun borrowNFTPublic(id: UInt64): &FlowZips.NFT{FlowZips.NFTPublic}? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow FlowZip reference: The ID of the returned reference is incorrect"
            }
        }
    }

    pub resource interface CollectionOwner {
        pub fun borrowNFTOwner(id: UInt64): &FlowZips.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow NFT reference: The ID of the returned reference is incorrect"
            }
        }
        pub fun zipZip(id: UInt64, zipData: String)
        pub fun unzipZip(id: UInt64)
    }

    // Collection
    // A collection of FlowZip NFTs owned by an account
    //
    pub resource Collection: CollectionPublic, CollectionOwner, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }

        // withdraw 
        // removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit 
        // takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @FlowZips.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            // update the holders list
            FlowZips.holders[id] = self.owner?.address

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs 
        // returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT 
        // gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        // borrowFlowZip
        // Gets a reference to an NFT in the collection as a FlowZip,
        // exposing all of its fields (including the typeID & rarityID).
        // This is safe as there are no functions that can be called on the FlowZip.
        //
        pub fun borrowFlowZip(id: UInt64): &FlowZips.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &FlowZips.NFT
            } else {
                return nil
            }    
        }

        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let flowZip = nft as! &FlowZips.NFT
            return flowZip as &AnyResource{MetadataViews.Resolver}
        }

        // Public
        pub fun borrowNFTPublic(id: UInt64): &FlowZips.NFT{FlowZips.NFTPublic}? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                let flowZip = nft as! &FlowZips.NFT
                return flowZip as &FlowZips.NFT{FlowZips.NFTPublic}  
            } else {
                return nil
            }          
        }

        pub fun getZip(id: UInt64) {
            let ref = self.borrowNFTPublic(id: id)
            ref?.getZip()        
        }

        // Owner only
        // Zip related functions
        pub fun borrowNFTOwner(id: UInt64): &FlowZips.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &FlowZips.NFT
            } else {
                return nil
            }    
        }

        pub fun zipZip(id: UInt64, zipData: String) {
            let ref = self.borrowNFTOwner(id: id)
            ref?.zipZip(zipData)
        }

        pub fun unzipZip(id: UInt64) {
            let ref = self.borrowNFTOwner(id: id)
            ref?.unzipZip()
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // public mint
    // allow anyone to mint
    pub fun mintNFT(
        recipient: &{NonFungibleToken.CollectionPublic}, 
        kind: Kind, 
        rarity: Rarity,
        royalties: [MetadataViews.Royalty],
        zipName: String,
        zipValue: String
    ) {
        let metadata: {String: AnyStruct} = {}
        let currentBlock = getCurrentBlock()
        metadata["mintedBlock"] = currentBlock.height
        metadata["mintedTime"] = currentBlock.timestamp
        metadata["minter"] = recipient.owner!.address

        // this piece of metadata will be used to show embedding rarity into a trait
        // metadata["foo"] = "bar"

        metadata["zipName"] = zipName
        metadata["zipValue"] = zipValue

        // create a new NFT
        var newNFT <- create FlowZips.NFT(
            id: FlowZips.totalSupply,
            royalties: royalties,
            metadata: metadata,
            kind: kind, 
            rarity: rarity
        )

        // deposit it in the recipient's account using their reference
        recipient.deposit(token: <-newNFT)

        emit Minted(
            id: FlowZips.totalSupply,
            kind: kind.rawValue,
            rarity: rarity.rawValue,
        )

        FlowZips.totalSupply = FlowZips.totalSupply + 1
    }

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter {

        // mintNFT
        // Mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        //
        pub fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic}, 
            kind: Kind, 
            rarity: Rarity,
            royalties: [MetadataViews.Royalty],
        ) {
            let metadata: {String: AnyStruct} = {}
            let currentBlock = getCurrentBlock()
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp
            metadata["minter"] = recipient.owner!.address

            // this piece of metadata will be used to show embedding rarity into a trait
            // metadata["foo"] = "bar"

            // create a new NFT
            var newNFT <- create FlowZips.NFT(
                id: FlowZips.totalSupply,
                royalties: royalties,
                metadata: metadata,
                kind: kind, 
                rarity: rarity
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            emit Minted(
                id: FlowZips.totalSupply,
                kind: kind.rawValue,
                rarity: rarity.rawValue,
            )

            FlowZips.totalSupply = FlowZips.totalSupply + UInt64(1)
        }

        // Update NFT images for new type
        pub fun addNewImagesForKind(from: AuthAccount, newImages: {Kind: {Rarity: String}}) {
            let kindValue = FlowZips.images.containsKey(newImages.keys[0]) 
            if(!kindValue) {
                FlowZips.images.insert(key: newImages.keys[0], newImages.values[0])
                emit ImagesAddedForNewKind(
                    kind: newImages.keys[0].rawValue,
                )
            } else {
                panic("No Rugs... Can't update existing NFT images.")
            }
        }
    }

    // fetch
    // Get a reference to a FlowZip from an account's Collection, if available.
    // If an account does not have a FlowZips.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &FlowZips.NFT? {
        let collection = getAccount(from)
            .getCapability(FlowZips.CollectionPublicPath)!
            .borrow<&FlowZips.Collection{FlowZips.CollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust FlowZips.Collection.borowFlowZip to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowFlowZip(id: itemID)
    }

    // initializer
    //
    init() {
        // set rarity price mapping
        self.itemRarityPriceMap = {
            Rarity.gold: 125.0,
            Rarity.purple: 25.0,
            Rarity.green: 5.0,
            Rarity.blue: 1.0
        }

        self.images = {
            Kind.fishbowl: {
                Rarity.blue: "bafybeibuqzhuoj6ychlckjn6cgfb5zfurggs2x7pvvzjtdcmvizu2fg6ga",
                Rarity.green: "bafybeihbminj62owneu3fjhtqm7ghs7q2rastna6srqtysqmjcsicmn7oa",
                Rarity.purple: "bafybeiaoja3gyoot4f5yxs4b7tucgaoj3kutu7sxupacddxeibod5hkw7m",
                Rarity.gold: "bafybeid73gt3qduwn2hhyy4wzhsvt6ahzmutiwosfd3f6t5el6yjqqxd3u"
            },
            Kind.fishhat: {
                Rarity.blue: "bafybeigu4ihzm7ujgpjfn24zut6ldrn7buzwqem27ncqupdovm3uv4h4oy",
                Rarity.green: "bafybeih6eaczohx3ibv22bh2fsdalc46qaqty6qapums6zhelxet2gfc24",
                Rarity.purple: "bafybeifbhcez3v5dj5qgndrx73twqleajz7r2mog4exd7abs3aof7w3hhe",
                Rarity.gold: "bafybeid2r5q3vfrsluv7iaelqobkihfopw5t4sv4z2llxsoe3xqfynl73u"
            },
            Kind.milkshake: {
                Rarity.blue: "bafybeialhf5ga6owaygebp6xt4vdybc7aowatrscwlwmxd444fvwyhcskq",
                Rarity.green: "bafybeihjy4rcbvnw6bcz3zbirq5u454aagnyzjhlrffgkc25wgdcw4csoe",
                Rarity.purple: "bafybeidbua4rigbcpwutpkqvd7spppvxemwn6o2ifhq6xam4sqlngzrfiq",
                Rarity.gold: "bafybeigdrwjq4kge3bym2rbnek2olibdt5uvdbtnuwto36jb36cr3c4p5y"
            },
            Kind.tuktuk: {
                Rarity.blue: "bafybeidjalsqnhj2jnisxucv6chlrfwtcrqyu2n6lpx3zpuuv2o3d3nwce",
                Rarity.green: "bafybeiaeixpd4htnngycs7ebktdt6crztvhyiu2js4nwvuot35gzvszchi",
                Rarity.purple: "bafybeihfcumxiobjullha23ov77wgd5cv5uqrebkik6y33ctr5tkt4eh2e",
                Rarity.gold: "bafybeigdi6ableh5mvvrqdil233ucxip7cm3z4kpnpxhutfdncwhyl22my"
            },
            Kind.skateboard: {
                Rarity.blue: "bafybeic55lpwfvucmgibbvaury3rpeoxmcgyqra3vdhjwp74wqzj6oqvpq",
                Rarity.green: "bafybeic55lpwfvucmgibbvaury3rpeoxmcgyqra3vdhjwp74wqzj6oqvpq",
                Rarity.purple: "bafybeiepqu75oknv2vertl5nbq7gqyac5tbpekqcfy73lyk2rcjgz7irpu",
                Rarity.gold: "bafybeic5ehqovuhix4lyspxfawlegkrkp6aaloszyscmjvmjzsbxqm6s2i"
            }
        }

        // Initialize the total supply
        self.totalSupply = 0

        // holders
        self.holders = {}

        // Set our named paths
        self.CollectionStoragePath = /storage/flowZipsCollection
        self.CollectionPublicPath = /public/flowZipsCollection
        self.MinterStoragePath = /storage/flowZipsMinter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // Create a public capability for the collection
        self.account.link<&FlowZips.Collection{NonFungibleToken.CollectionPublic, FlowZips.CollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}
