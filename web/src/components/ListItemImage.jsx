import PropTypes from "prop-types"
import {itemGradientClass} from "src/util/classes"

// Fixed aspect ratio prevents content reflow
const getContainerStyle = (isStoreItem) => {
  if(!isStoreItem) return {
    //width: "100%",
    //height: 0,
    //overflow: "hidden",
    //paddingBottom: isStoreItem ? "111%" : "125%",
    width: "100%",
  }
}


const getImageSrc = (cid, size, is2X) => {
  return `https://${cid}.ipfs.dweb.link/${size}${is2X ? "@2x" : ""}.png`
}

export default function ListItemImage({
  name,
  rarity,
  cid,
  size = "sm",
  grayscale,
  classes = "",
  isStoreItem,
  children,
  zipName,
  zipValue,
  zipStatus,
}) {
  if (typeof rarity === "undefined") return <div className="w-full" />
  const imageSrc1X = getImageSrc(cid, size, false)
  const imageSrc2X = getImageSrc(cid, size, true)
  const imageSrcSet = `${imageSrc1X}, ${imageSrc2X} 2x`

  return (
    <div
      className={`group relative ${itemGradientClass(
        grayscale ? "gray" : rarity
      )} item-image-container rounded-xl relative grid grid-cols-6 w-96 h-64 items-center justify-center ${classes}`}
      style={getContainerStyle(isStoreItem)}
    >
        <div className="col-start-4 col-end-7 h-10">
          <div className="text-right text-white pr-4 text-xl">$ {zipValue}</div>
        </div>
        <div className="col-start-1 col-end-7 grid place-content-center">
          <div className="text-white text-3xl">{zipName}</div>
        </div>
        <div className="col-start-1 col-end-7 h-10">
          <div className="text-center text-white mt-4">
            {(zipStatus === "blank" || zipStatus === "empty") && <span className="bg-zinc-400 rounded-full text-white py-2 px-10">blank</span>}
            {(zipStatus === "zipped") && <span className="bg-green-600 rounded-full text-white py-2 px-10">zipped 🤐</span>}
            {(zipStatus === "unzipped") && <span className="bg-red-600 rounded-full text-white py-2 px-10">unzipped 😱</span>}
          </div>
        </div>
      {/*<div className="col-start-1 col-end-7 grid place-content-center">
        <img src={imageSrc1X} srcSet={imageSrcSet} alt={name} className="h-64 justify-self-center"/>
      </div>*/}
      {children}
    </div>
  )
}

ListItemImage.propTypes = {
  name: PropTypes.string,
  rarity: PropTypes.number,
  cid: PropTypes.string,
  size: PropTypes.string,
  classes: PropTypes.string,
  grayscale: PropTypes.bool,
  isStoreItem: PropTypes.bool,
  children: PropTypes.node,
  zipName: PropTypes.string,
  zipValue: PropTypes.string,
  zipStatus: PropTypes.string,
}
