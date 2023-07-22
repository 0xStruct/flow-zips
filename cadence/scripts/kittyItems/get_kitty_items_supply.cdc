import FlowZips from "../../contracts/FlowZips.cdc"

// This scripts returns the number of KittyItems currently in existence.

pub fun main(): UInt64 {    
    return FlowZips.totalSupply
}
