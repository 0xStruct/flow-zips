import {useState, useEffect} from "react"
import {useRouter} from "next/dist/client/router"
import ListItemImage from "src/components/ListItemImage"
import ListItemPageButtons from "src/components/ListItemPageButtons"
import ListItemPrice from "src/components/ListItemPrice"
import OwnerInfo from "src/components/OwnerInfo"
import PageTitle from "src/components/PageTitle"
import RarityScale from "src/components/RarityScale"

//import SellListItem from "src/components/SellListItem"
import ZipZip from "src/components/ZipZip"
import ZipUnzip from "src/components/ZipUnzip"
import ListZip from "src/components/ListZip"

import useAccountItem from "src/hooks/useAccountItem"
import useApiListing from "src/hooks/useApiListing"
import useAppContext from "src/hooks/useAppContext"
import AccountItemNotFoundMessage from "src/components/AccountItemNotFoundMessage"

export default function KittyItem() {
  const router = useRouter()
  const {currentUser} = useAppContext()
  const {address, id} = router.query
  const {listing} = useApiListing(id)
  const {item} = useAccountItem(address, id, listing)
  const currentUserIsOwner =
    currentUser && item?.owner && item.owner === currentUser?.addr
  const isSellable = currentUserIsOwner && !listing

  const [itemStatus, setItemStatus] = useState(item?.zipStatus || "blank")

  if(item) console.log(`item ${item.itemID}: `, item)

  return (
    <div className="main-container pt-12 pb-24 w-full">
      <PageTitle>{["Kitty Item", id].filter(Boolean).join(" ")}</PageTitle>
      <main>
        {!!item ? (
          <div className="grid grid-cols-1 lg:grid-cols-1 justify-items-center">
            <ListItemImage
              name={item?.name}
              rarity={item?.rarity}
              cid={item?.image}
              address={item?.owner}
              id={item?.itemID}
              isStoreItem={true}
              size="lg"
              classes="item-image-container-hover"
              zipStatus={itemStatus}
              zipValue={item?.zipValue}
              zipName={item?.zipName}
            />
            <OwnerInfo address={item.owner}/>

            <div className="pt-5 w-6/12">
              {/*<h1
                className="text-2xl text-gray-darkest mt-5 mb-5"
                data-cy="minted-item-name"
              >
                {item.name}
              </h1>*/}
              {itemStatus === "blank" && currentUserIsOwner &&
                <ZipZip item={item} setItemStatus={setItemStatus} className="mt-4 mb-10" />
              }

              {(itemStatus === "zipped" || itemStatus === "unzipped") && currentUserIsOwner &&
                <ZipUnzip item={item} setItemStatus={setItemStatus} className="mt-4 mb-10" />
              }
              
              <hr className="my-4"/>
              {isSellable ? (
                <ListZip item={item} />
              ) : (
                <>
                  <div className="flex items-center my-5">
                    {!!listing && (
                      <div className="">
                        Listing Price:{"           "}
                        <ListItemPrice price={listing.price} />
                      </div>
                    )}
                    {/*<div className="font-mono text-sm">#{id}</div>*/}
                  </div>

                  {/*<div className="mt-8">
                    <RarityScale highlightedRarity={item.rarity} />
                  </div>*/}
                  <ListItemPageButtons item={item} />
                </>
                    )}
            </div>
          </div>
        ) : (
          <AccountItemNotFoundMessage itemID={id} accountID={address} />
        )}
      </main>
    </div>
  )
}
