const { ethers, run } = require("hardhat");

async function main() {
  console.log("Deploying FriendtechSharesV1...");
  const UserProfileFactory = await ethers.getContractFactory(
    "FriendtechSharesV1"
  );
  const UserProfile = await UserProfileFactory.deploy();
  console.log(`FriendtechSharesV1 deployed at: ${UserProfile.address}`);

  console.log("Verifying ...");
  await UserProfile.deployTransaction.wait(5);
  await run("verify:verify", {
    address: UserProfile.address,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
