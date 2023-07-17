import * as fcl from "@onflow/fcl"
import {useRouter} from "next/router"
import {useEffect, useRef, useState} from "react"
import useTransactionsContext from "src/components/Transactions/useTransactionsContext"
import {paths} from "src/global/constants"
import publicConfig from "src/global/publicConfig"
import useRequest from "src/hooks/useRequest"
import useAppContext from "src/hooks/useAppContext"
import {EVENT_ITEM_MINTED, getKittyItemsEventByType} from "src/util/events"
import {useSWRConfig} from "swr"
import analytics from "src/global/analytics"

// Mint Zip with NFT values entered by minter
export default function useMintZip() {
  const {addTransaction} = useTransactionsContext()
  const [_mintState, executeMintRequest] = useRequest()
  const txStateSubscribeRef = useRef()
  const txSealedTimeout = useRef()
  const {currentUser} = useAppContext()

  //console.log("currentUser: ", currentUser)

  const router = useRouter()
  const {mutate} = useSWRConfig()

  const [isMintingLoading, setIsMintingLoading] = useState(false)
  const [transactionStatus, setTransactionStatus] = useState(null)
  const transactionAction = isMintingLoading ? "Minting Zip" : "Processing"

  const resetLoading = () => {
    setIsMintingLoading(false)
    setTransactionStatus(null)
  }

  const onTransactionSealed = tx => {
    if (!!tx.errorMessage?.length) {
      resetLoading()
      return
    }

    const event = getKittyItemsEventByType(tx.events, EVENT_ITEM_MINTED)

    if (!event?.data?.id)
      throw new Error("Minting error, missing itemID")
    if (!event?.data?.kind)
      throw new Error("Minting error, missing kind")

    // TODO: Poll api for listing presence before mutating the apiMarketItemsList
    txSealedTimeout.current = setTimeout(() => {
      //mutate(paths.apiMarketItemsList())
      router.push({
        pathname: paths.profileItem(currentUser.addr.toString(), event.data.id),
      })
    }, 1000)
  }

  const mintZip = () => {
    setIsMintingLoading(true)
    // const recipient = publicConfig.flowAddress
    // recipient is the current logged in user
    const recipient = currentUser.addr.toString()

    executeMintRequest({
      url: publicConfig.apiKittyItemMint,
      method: "POST",
      data: {
        recipient,
      },
      onSuccess: data => {
        setIsMintingLoading(true)

        const transactionId = data?.transaction
        if (!transactionId) throw new Error("Missing transactionId")
        addTransaction({id: transactionId, title: "Minting new zip"})

        txStateSubscribeRef.current = fcl.tx(transactionId).subscribe(tx => {
          setTransactionStatus(tx.status)
          if (fcl.tx.isSealed(tx)) onTransactionSealed(tx)
        })

        analytics.track("kitty-items-item-minted", {params: {mint: data}})
      },
      onError: () => {
        resetLoading()
      },
    })
  }

  useEffect(() => {
    return () => {
      if (!!txStateSubscribeRef.current) txStateSubscribeRef.current()
      clearTimeout(txSealedTimeout.current)
    }
  }, [])

  const isLoading = isMintingLoading
  return [{isLoading, transactionAction, transactionStatus}, mintZip]
}
