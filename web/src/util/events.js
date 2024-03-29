import * as fcl from "@onflow/fcl"
import publicConfig from "src/global/publicConfig"

export const EVENT_ITEM_MINTED = "FlowZips.Minted"
export const EVENT_KITTY_ITEM_DEPOSIT = "FlowZips.Deposit"

export const EVENT_LISTING_AVAILABLE = "NFTStorefrontV2.ListingAvailable"
export const EVENT_LISTING_COMPLETED = "NFTStorefrontV2.ListingCompleted"

export const getKittyItemsEventByType = (events, type) => {
  return events.find(
    event =>
      event.type ===
      `A.${fcl.sansPrefix(publicConfig.contractFlowZips)}.${type}`
  )
}

export const getStorefrontEventByType = (events, type) => {
  return events.find(
    event =>
      event.type ===
      `A.${fcl.sansPrefix(publicConfig.contractNftStorefront)}.${type}`
  )
}
