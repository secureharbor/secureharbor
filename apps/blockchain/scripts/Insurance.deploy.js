require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

const main = async () => {
  const ethers = hre.ethers;

  // Get the signer to deploy the contract
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy the InsuranceSettlement contract
  const InsuranceSettlement = await ethers.getContractFactory("InsuranceSettlement");
  const insuranceSettlement = await InsuranceSettlement.deploy();
  await insuranceSettlement.deployed();

  console.log("InsuranceSettlement deployed to:", insuranceSettlement.address);

  // Settle claim by transferring 0.001 ETH to the specified address
  const recipientAddress = "0xEd602BAe30F65CbFC6C50598f130c4D18C4362DA";
  const amount = ethers.utils.parseEther("0.001"); // Converts 0.001 ETH to Wei

  // Ensure the contract has enough balance
  // If not, you might need to send ETH to the contract first
  console.log("Transferring 0.001 ETH to the contract for funding...");
  const tx1 = await deployer.sendTransaction({
    to: insuranceSettlement.address,
    value: amount,
  });
  await tx1.wait();
  console.log("Funding complete.");

  console.log(`Settling claim: sending 0.001 ETH to ${recipientAddress}`);
  const tx2 = await insuranceSettlement.settleClaim(recipientAddress, amount);
  await tx2.wait();

  console.log(`Claim settled. Transaction hash: ${tx2.hash}`);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
