import { useEffect, useState } from "react"
import Button from "src/components/Button"
import { ITEM_RARITY_PRICE_MAP } from "src/global/constants"
import { normalizedItemType } from "src/global/types"
//import useItemSale from "src/hooks/useItemSale"
import useZipUnzip from "src/hooks/useZipUnzip"
import { formattedCurrency } from "src/util/currency"
import TextInput from "./TextInput"
import TransactionLoading from "./TransactionLoading"

import lit from 'src/util/lit';

export default function ZipUnzip({ item, setItemStatus }) {
  const [zipUnzip, tx] = useZipUnzip(item.itemID)

  const [btnDisabled, setBtnDisabled] = useState(false)

  const [unzipped, setUnzipped] = useState(false)
  const [secret, setSecret] = useState("")

  const doZipUnzip = async () => {
    setBtnDisabled(true)
    await zipUnzip(item)
    await decryptText()
  }

  const decryptText = async () => {
    // get encryptedDataURI and encryptedSymmetricKey zipData
    console.log(item.zipData.split("<zip>"))
    const encryptedDataURI = item.zipData.split("<zip>")[0]
    const encryptedSymmetricKey = item.zipData.split("<zip>")[1]

    console.log("encryptedDataURI: ", encryptedDataURI);
    console.log("encryptedSymmetricKey: ", encryptedSymmetricKey);

    const encryptedDataURIBlob = await (await fetch(encryptedDataURI)).blob(); 

    try {
      const decryptedString = await lit.decryptText(encryptedDataURIBlob, encryptedSymmetricKey, item.itemID);
      //setDecryptedText(decryptedString);

      setUnzipped(true)
      setItemStatus("unzipped")
      setSecret(decryptedString)
    } catch (error) {
      alert(noAuthError);
    }
  }

  const onSubmit = e => {
    e.preventDefault()
  }

  return (
    <div data-cy="sell-list-item">
      <div className="bg-white border border-gray-200 rounded px-8 pt-5 pb-7">
        <div className="text-gray mb-5">
            <div className="font-bold mb-2">
            Unzip to reveal secret code
            </div>
            <div className="mb-2">
            Secret code can be decrypted only by the owner of NFT by combining distributed partial keys across various nodes. 
            No single node holds the full complete key.
            </div>
            <div className="mb-2">
            Secret code can only be decrypted/unzipped by proving ownership of the NFT.
            Upon first unzip, the NFT is marked as unzipped forever.
            </div>
        </div>

        {!!tx ? (
          <TransactionLoading status={tx.status} />
        ) : (
          <>
            {unzipped === true &&
                <>
                <em>Reveal your secret below:</em>
                <div className="rounded-full h-12 bg-gray-600 relative mt-4 hover:bg-gray-200">
                    <div className="opacity-0 hover:opacity-100 duration-800 absolute inset-0 z-10 flex justify-center items-center text-xl text-black font-semibold">
                        {secret}
                    </div>
                </div>
                </>
            }
            {unzipped === false &&
                <Button
                    type="button"
                    disabled={btnDisabled}
                    roundedFull={true}
                    className="mt-5"
                    onClick={doZipUnzip}
                >
                    Unzip
                </Button>
            }
          </>
        )}
      </div>
    </div>
  )
}

ZipUnzip.propTypes = {
  item: normalizedItemType,
}
