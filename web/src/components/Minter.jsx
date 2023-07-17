import Button from "src/components/Button"
//import useMintZip from "src/hooks/useMintZip"
//import useMintAndList from "src/hooks/useMintAndList"
import useZipMint from "src/hooks/useZipMint"
import MinterLoader from "./MinterLoader"
import { itemGradientClass } from "src/util/classes"
import RarityScale from "./RarityScale"
import TransactionLoading from "./TransactionLoading"
import useItemSale from "src/hooks/useItemSale"
import { useState } from "react"
import useAppContext from "src/hooks/useAppContext"

import TextInput from "./TextInput"
import Select from "./Select"


export default function Minter() {
  //const [{ isLoading, transactionStatus }, mint] = useMintAndList()

  const imageSrc1X = "/images/kitty-items/question-gray-lg.png"
  const imageSrc2X = "/images/kitty-items/question-gray-lg@2x.png"
  const imageSrcSet = `${imageSrc1X}, ${imageSrc2X} 2x`

  const {currentUser} = useAppContext()

  //const [sell, tx] = useItemSale(item.itemID)
  const [zipMint, tx] = useZipMint()

  const [value, setValue] = useState("10")
  const [name, setName] = useState("Spotify Topup")
  const [color, setColor] = useState("1")
  const [image, setImage] = useState()

  const COLOR_OPTIONS = [
    { label: "Blue", value: "0" },
    { label: "Green", value: "1" },
    { label: "Purple", value: "2" },
    { label: "Gold", value: "3" }
  ]

  const IMAGE_OPTIONS = [
    { label: "Blue", value: "0" },
    { label: "Green", value: "1" },
    { label: "Purple", value: "2" },
    { label: "Gold", value: "3" }
  ]

  const onSubmit = e => {
    e.preventDefault()
  }

  const doZipMint = (e) => {
    e.preventDefault()
    zipMint(currentUser.addr.toString(), name, value, color)
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-1 justify-items-center">
      {/*<MinterLoader isLoading={isLoading} />*/}


      <div
        className={`group relative ${itemGradientClass(
          color
        )} rounded-xl relative grid grid-cols-6 w-96 h-64`}
      >
        <div className="col-start-4 col-end-7 h-10">
          <div className="text-right text-white mt-4 pr-4 text-xl">$ {value}</div>
        </div>
        <div className="col-start-1 col-end-7 grid place-content-center">
          <div className="text-white text-4xl">{name}</div>
        </div>
        <div className="col-start-4 col-end-7 h-10">
          <div className="text-right text-white mt-4 pr-4 text-lg"> </div>
        </div>
        {/*<img src={imageSrc1X} srcSet={imageSrcSet} alt="Mint a Zip" className="h-48" />*/}
      </div>


      <div className="flex flex-col w-6/12 mt-10">
        <h1 className="mb-4 text-2xl text-gray-darkest" data-cy="header-mint">
          Mint a Zip 🤐
        </h1>
        {/*<RarityScale />*/}

        <div className="bg-white border border-gray-200 rounded px-8 pt-5 pb-7">
          {!!tx ? (
            <TransactionLoading status={tx.status} />
          ) : (
            <form onSubmit={onSubmit}>
              <TextInput
                value={name}
                onChange={setName}
                type="text"
                required={true}
                placeholder="Netflix Topup Card"
                label="Name"
                inputClassName="text-left pl-4"
              />

              <TextInput
                value={value}
                onChange={setValue}
                type="number"
                min="0"
                required={true}
                placeholder="10.00"
                label="Value"
                inputClassName="text-left pr-4"
                step="any"
              />

              {/*<Select
                label="Image"
                options={IMAGE_OPTIONS}
                value={image}
                onChange={setImage}
              />*/}

              <Select
                label="Color"
                options={COLOR_OPTIONS}
                value={color}
                onChange={setColor}
              />
              <Button onClick={doZipMint} roundedFull={true} className="mt-5">
                Mint
              </Button>
            </form>
          )}
        </div>
      </div>
    </div>
  )
}
