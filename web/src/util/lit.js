//import * as LitJsSdk from '@lit-protocol/lit-node-client';
import * as LitJsSdk from "@lit-protocol/lit-node-client-nodejs";
import * as u8a from "uint8arrays";
import { ethers } from "ethers";
import { SiweMessage } from "siwe";

const client  = new LitJsSdk.LitNodeClientNodeJs({
  litNetwork: "serrano",
  alertWhenUnauthorized: false,
  debug: true,
});

const chain = "ethereum";

// QmU7A2mRmqJtvmGTscQVnszGYLy1u15ivgtYwSLoGG1qoD
// immutable contract code in JS (uploaded to IPFS) is used by LIT Protocol nodes
var accessControlConditions = [
  {
    contractAddress: "ipfs://QmU7A2mRmqJtvmGTscQVnszGYLy1u15ivgtYwSLoGG1qoD",
    standardContractType: "LitAction",
    chain: "ethereum",
    method: "go",
    parameters: ["150"],
    returnValueTest: {
      comparator: "=",
      value: "true",
    },
  },
];

/**
 * Get auth signature using siwe
 * @returns 
 */
const signAuthMessage = async () => {

  // Replace this with your private key
  // 0xcD9527b1e742440D6A06E3646102EaBf76963C77
  console.log(process.env.ETH_PRIVATE_KEY)
  const privKey = process.env.ETH_PRIVATE_KEY;
  const privKeyBuffer = u8a.fromString(privKey, "base16");
  const wallet = new ethers.Wallet(privKeyBuffer);

  const domain = "localhost";
  const origin = "https://localhost/login";
  const statement = "please sign";

  const siweMessage = new SiweMessage({
      domain,
      address: wallet.address,
      statement,
      uri: origin,
      version: "1",
      chainId: "1",
  });

  const messageToSign = siweMessage.prepareMessage();

  const signature = await wallet.signMessage(messageToSign);

  console.log("signature", signature);

  const recoveredAddress = ethers.utils.verifyMessage(messageToSign, signature);

  const authSig = {
      sig: signature,
      derivedVia: "web3.eth.personal.sign",
      signedMessage: messageToSign,
      address: recoveredAddress,
  };

  return authSig;
}

class Lit {
  litNodeClient;

  async connect() {
    await client.connect();
    this.litNodeClient = client;
  }

  async encryptText(text) {
    if (!this.litNodeClient) {
      await this.connect();
    }
    //const authSig = await LitJsSdk.checkAndSignAuthMessage({ chain });
    // authSig is not sensitive in the process but it will be generated one each for an nft later
    // authSig session does expire, so there needs an api call for authSig
    const authSig = await signAuthMessage();
    console.log("authSig: ", authSig)
    const { encryptedString, symmetricKey } = await LitJsSdk.encryptString(text);

    const encryptedSymmetricKey = await this.litNodeClient.saveEncryptionKey({
      accessControlConditions: accessControlConditions,
      symmetricKey,
      authSig,
      chain,
    });

    return {
        encryptedString,
        encryptedSymmetricKey: LitJsSdk.uint8arrayToString(encryptedSymmetricKey, "base16")
    };
  }

  async decryptText(encryptedString, encryptedSymmetricKey) {
    if (!this.litNodeClient) {
      await this.connect();
    }

    //const authSig = await LitJsSdk.checkAndSignAuthMessage({ chain });
    // authSig is not sensitive in the process but it will be generated one each for an nft later
    // authSig session does expire, so there needs an api call for authSig
    const authSig = await signAuthMessage();
    const symmetricKey = await this.litNodeClient.getEncryptionKey({
        accessControlConditions: accessControlConditions,
        toDecrypt: encryptedSymmetricKey,
        chain,
        authSig
    });

    const decryptedString = await LitJsSdk.decryptString(
        encryptedString,
        symmetricKey
    );
    return decryptedString;
  }
}

export default new Lit();
