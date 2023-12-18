const { ethers } = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  const Storage = await ethers.getContractFactory('Storage');
  const storage = await Storage.deploy();
  await storage.deployed();

  console.log('Storage deployed to :', storage.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
