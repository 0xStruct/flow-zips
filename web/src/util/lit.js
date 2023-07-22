//import * as LitJsSdk from '@lit-protocol/lit-node-client';
import * as LitJsSdk from "@lit-protocol/lit-node-client-nodejs";
import * as u8a from "uint8arrays";
import { ethers } from "ethers";
import { SiweErrorType, generateNonce, SiweMessage } from 'siwe';

const client  = new LitJsSdk.LitNodeClientNodeJs({
  litNetwork: "serrano",
  alertWhenUnauthorized: false,
  debug: true,
});

const chain = "ethereum";


// QmYFJF215KXu8WmojNPW1nPGCMmThHF9jeEPqN18M2FCLM
// immutable contract code in JS (uploaded to IPFS) is used by LIT Protocol nodes
const getAccessControlConditions = (zipId) => {
  //console.log("btoa: ", btoa(`{"type":"UInt64","value":"${zipId}"}`))

  return [
    {
      // ipfs address of the immutable Lit Action Code
      contractAddress: "ipfs://QmYFJF215KXu8WmojNPW1nPGCMmThHF9jeEPqN18M2FCLM",
      standardContractType: "LitAction",
      chain: "ethereum", // not relevant
      method: "go",
      parameters: [btoa(`{"type":"UInt64","value":"${zipId}"}`)],
      returnValueTest: {
        comparator: "=",
        value: "eyJ2YWx1ZSI6dHJ1ZSwidHlwZSI6IkJvb2wifQo=", // base64 of true output from Flow Access API
      },
    },
  ];
} 

/**
 * Get auth signature using siwe
 * @returns 
 */
const signAuthMessage = async () => {

  // Replace this with your private key
  // 0xcD9527b1e742440D6A06E3646102EaBf76963C77
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
      version: '1',
      chainId: '1'
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

  async encryptText(text, zipId) {
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
      accessControlConditions: getAccessControlConditions(zipId),
      symmetricKey,
      authSig,
      chain,
    });

    return {
        encryptedString,
        encryptedSymmetricKey: LitJsSdk.uint8arrayToString(encryptedSymmetricKey, "base16")
    };
  }

  async decryptText(encryptedString, encryptedSymmetricKey, zipId) {
    if (!this.litNodeClient) {
      await this.connect();
    }

    //const authSig = await LitJsSdk.checkAndSignAuthMessage({ chain });
    // authSig is not sensitive in the process but it will be generated one each for an nft later
    // authSig session does expire, so there needs an api call for authSig
    const authSig = await signAuthMessage();
    const symmetricKey = await this.litNodeClient.getEncryptionKey({
        accessControlConditions: getAccessControlConditions(zipId),
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
