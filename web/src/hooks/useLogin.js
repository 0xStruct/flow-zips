import * as fcl from "@onflow/fcl"
import {useRouter} from "next/router"
import {paths} from "src/global/constants"
import analytics, {event} from "src/global/analytics"
import useAppContext from "src/hooks/useAppContext" 

export default function useLogin() {
  const router = useRouter()
  const {setCurrentUser} = useAppContext()

  const logIn = async (redirect = true) => {
    const user = await fcl.logIn()
    if (user.addr) {
      setCurrentUser(user)
      //analytics.identify(user.addr, {})
      //analytics.track("kitty-items-user-login", {params: {user: user.addr}})
      router.push(paths.profile(user.addr))
    }
  }

  return logIn
}
