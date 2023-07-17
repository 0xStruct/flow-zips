import * as fcl from "@onflow/fcl"
import ZIP_MINT_TX_CDC from "cadence/transactions/zip_mint.cdc"
import {useEffect, useState} from "react"
import { useRouter } from "next/router"
import useTransactionsContext from "src/components/Transactions/useTransactionsContext"
import {isSuccessful} from "src/components/Transactions/utils"
import {paths} from "src/global/constants"
import {uFix64String} from "src/util/currency"
import {
  EVENT_LISTING_AVAILABLE,
  getStorefrontEventByType,
} from "src/util/events"
import useApiListing from "./useApiListing"
import analytics from "src/global/analytics"

export default function useZipMint() {
  const {addTransaction, transactionsById} = useTransactionsContext()
  const [txId, setTxId] = useState()
  const tx = transactionsById[txId]?.data
  const router = useRouter()
  const [currentUserAddr, setCurrentUserAddr] = useState()

  if(isSuccessful(tx)) {
    console.log(tx);
    if(tx.events?.[1].data.id) {
        setTxId(null)
        router.push({
            pathname: paths.profileItem(currentUserAddr, tx.events?.[1].data.id),
        })
    }

  }

  // Poll for api listing once tx is successful
  const {listing} = {listing: null}
  /*const {listing} = useApiListing(
    itemID,
    () => {
      if (isSuccessful(tx)) {
        analytics.track("kitty-items-item-listed", {params: {itemID}})
        return paths.apiListing(itemID)
      }
      return null
    },
    {
      refreshInterval: 1000,
    }
  )*/

  const zipMint = async (recipient, zipName, zipValue, color) => {
    //if (!item) throw new Error("Missing item")
    if (!recipient) throw new Error("Need to be logged in to mint")

    setCurrentUserAddr(recipient)

    const newTxId = await fcl.mutate({
      cadence: ZIP_MINT_TX_CDC,
      args: (arg, t) => [
        arg(recipient.toString(), t.Address),
        arg(zipName, t.String),
        arg(zipValue, t.String),
        arg(color.toString(), t.UInt8),
      ],
      limit: 1000,
    })

    addTransaction({
      id: newTxId,
      url: paths.profile(recipient),
      //title: `List ${item.name} #${item.itemID}`,
      title: `Minting for ${recipient}`
    })
    setTxId(newTxId)
  }

  useEffect(() => {
    if (!!listing) setTxId(null)
  }, [listing])

  useEffect(() => {
    console.log(txId)
  }, [txId])

  return [zipMint, tx]
}
