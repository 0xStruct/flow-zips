import {paths} from "src/global/constants"
import useAppContext from "src/hooks/useAppContext"
import Button, {ButtonLink} from "./Button"

export default function HomeEmptyMessage() {
  const {switchToAdminView} = useAppContext()
  return (
    <div
      className="flex justify-center my-12 text-center"
      data-cy="home-common"
    >
      <div className="bg-white border border-gray-200 p-6 w-[32rem] rounded-md inline-flex flex-col justify-center">
        <img
          src="/images/flow-zips.png"
          alt="Flow Zips"
          width="100"
          className="mx-auto mt-6 mb-4"
        />
        <h1 className="text-3xl font-semibold">Welcome to Flow Zips!</h1>
        <h3 className="text-xl font-semibold mb-6">
          Tokenize your secret codes and real world values
        </h3>

        <div className="bg-white border border-gray-200 p-6 rounded-md inline-flex flex-col justify-center">
          <b className="text-xl">Empowering trustless commerce</b>
          <em>For billions of $$$ in real world values</em>
          <p className="text-gray-light mb-5 mt-5">
            Buy / Sell / Trade secret codes, giftcard codes, event passes, recharge codes, etc
          </p>

          <Button onClick="/mint">
            MINT YOUR FIRST ZIP
          </Button>

          <hr className="mt-8 mb-6" />

          <b>Learn more about Flow Zips</b>
          <p className="text-gray-light mb-5 mt-1 max-w-xs mx-auto">
            Learn how distributed partial keys and multi-party computation safely keep your secrets private.
          </p>

          <ButtonLink href={paths.githubRepo} target="_blank" color="outline" className="mb-2">
            VIEW VIDEO DEMO
          </ButtonLink>
          <ButtonLink href={paths.githubRepo} target="_blank" color="outline" className="mb-2">
            CHECK GITHUB AND TECHNICAL DETAILS
          </ButtonLink>
        </div>
      </div>
    </div>
  )
}
