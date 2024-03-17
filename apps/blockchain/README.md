npm i

npx hardhat compile

npx hardhat run scripts/Insurance.deploy.js --network optimism


Sample request:

https://secureharbor.onrender.com/process-inputs?amount=150&companyWalletAddress=6hjiu3kjhf9783&userWalletAddress=098rwefskjdf13

Sample Response:


{"status":"success","message":"Claim received and processed successfully for the amount: 150. Smart contracts compiled and deployment script executed.","data":{"companyWalletAddress":"6hjiu3kjhf9783","userWalletAddress":"098rwefskjdf13","amount":"150","compileOutput":"Downloading compiler 0.8.20\nCompiled 1 Solidity file successfully (evm target: paris).\n","deploymentOutput":"Deploying contracts with the account: 0x51A86AD7B88Ec736dC25BB9723bD1601B3B15582\nAccount balance: 493325561331579903\nInsuranceSettlement deployed to: 0xFDaAcC96EdD30a82963a93EEB1ddf92EF1f21Bf3\nTransferring 0.001 ETH to the contract for funding...\nFunding complete.\nSettling claim: sending 0.001 ETH to 0xEd602BAe30F65CbFC6C50598f130c4D18C4362DA\nClaim settled. Transaction hash: 0x5443b76eac5a6bfddc2039d7d4b2f3a8dccbf89717defdbe234ef66c846a48f7\n"}}
