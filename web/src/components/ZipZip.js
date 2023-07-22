import { useState, useEffect } from "react"
import Button from "src/components/Button"
import { ITEM_RARITY_PRICE_MAP } from "src/global/constants"
import { normalizedItemType } from "src/global/types"
//import useItemSale from "src/hooks/useItemSale"
import useZipZip from "src/hooks/useZipZip"
import { formattedCurrency } from "src/util/currency"
import TextInput from "./TextInput"
import TransactionLoading from "./TransactionLoading"

import lit from 'src/util/lit';

export default function ZipZip({ item, setItemStatus }) {
  const [zipZip, tx] = useZipZip(item.itemID)

  const [secret, setSecret] = useState("")
  const [btnDisabled, setBtnDisabled] = useState(false)

  const doZipZip = async () => {
    setBtnDisabled(true)
    let zipData = await encryptText()
    console.log("zipData: ", zipData)
    zipZip(item, zipData)
  }

  useEffect(() => {
    if(tx?.status === 4) {
      console.log("tx success")
      setItemStatus("zipped")
    }
  }, [tx])

  const encryptText = async () => {
    if (secret.length === 0) {
      alert("Please enter a non-empty string!");
      return;
    }

    const { encryptedString, encryptedSymmetricKey } = await lit.encryptText(secret, item.itemID);

    const blobToDataURI = blob => {
      return new Promise((resolve, reject) => {
        var reader = new FileReader()

        reader.onload = e => {
          var data = e.target.result
          resolve(data)
        }
        reader.readAsDataURL(blob)
      })
    }
    const encryptedDataURI = await blobToDataURI(encryptedString)

    console.log("encryptedDataURI: ", encryptedDataURI)
    console.log("encryptedSymmetricKey: ", encryptedSymmetricKey)

    return encryptedDataURI +"<zip>"+ encryptedSymmetricKey
  }


  const onSubmit = e => {
    e.preventDefault()
  }

  return (
    <div data-cy="sell-list-item">
      <div className="bg-white border border-gray-200 rounded px-8 pt-5 pb-7">
        <div className="text-gray mb-5">
          <div className="font-bold mb-2">
            Zip secret code into NFT safely
          </div>
          <div className="mb-2">
            Secret code is encrypted in a decentralized manner by LIT protocol using multi-party computation across distributed nodes.
          </div>
          <div className="mb-2">
            Secret code can only be decrypted/unzipped by proving ownership of the NFT.
            Upon first unzip, the NFT is marked as unzipped forever.
          </div>
        </div>
        {!!tx ? (
          <TransactionLoading status={tx.status} />
        ) : (

          <form onSubmit={onSubmit}>
            <TextInput
              value={secret}
              onChange={setSecret}
              type="text"
              required={true}
              placeholder=""
              label="Secret"
              inputClassName="text-left pr-4"
            />
            <Button
              type="button"
              disabled={!secret || btnDisabled}
              roundedFull={true}
              className="mt-5"
              onClick={doZipZip}
            >
              Zip 🤐
            </Button>
          </form>
        )}
      </div>
    </div>
  )
}

ZipZip.propTypes = {
  item: normalizedItemType,
}
