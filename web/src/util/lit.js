import * as LitJsSdk from '@lit-protocol/lit-node-client';

const client = new LitJsSdk.LitNodeClient({
  alertWhenUnauthorized: false,
  litNetwork: "serrano",
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
    const authSig = {
      "sig": "0x746c42ed63cecaba9d91376dfeddd76d825b0e16303512c7ac7f1d7e24c1466750a440aecd5d99add16ef30eab25930d6ebd9d4f06ac4f61eaef5b5797c3dac41b",
      "derivedVia": "web3.eth.personal.sign",
      "signedMessage": "localhost:3002 wants you to sign in with your Ethereum account:\n0xF75a0001F014204CecD8c84A838495352c06178B\n\n\nURI: http://localhost:3002/\nVersion: 1\nChain ID: 1\nNonce: VSuoypVnDqyxL9DdV\nIssued At: 2023-07-17T13:07:41.436Z\nExpiration Time: 2023-07-18T13:07:41.371Z",
      "address": "0xf75a0001f014204cecd8c84a838495352c06178b"
    }
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
    const authSig = {
      "sig": "0x746c42ed63cecaba9d91376dfeddd76d825b0e16303512c7ac7f1d7e24c1466750a440aecd5d99add16ef30eab25930d6ebd9d4f06ac4f61eaef5b5797c3dac41b",
      "derivedVia": "web3.eth.personal.sign",
      "signedMessage": "localhost:3002 wants you to sign in with your Ethereum account:\n0xF75a0001F014204CecD8c84A838495352c06178B\n\n\nURI: http://localhost:3002/\nVersion: 1\nChain ID: 1\nNonce: VSuoypVnDqyxL9DdV\nIssued At: 2023-07-17T13:07:41.436Z\nExpiration Time: 2023-07-18T13:07:41.371Z",
      "address": "0xf75a0001f014204cecd8c84a838495352c06178b"
    }
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
