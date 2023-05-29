task("deploy", "Deploys the contract")
  .addParam("account", "The account's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const MarkerplaceFactory = await hre.ethers.getContractFactory(
        "NFTMarketplace", 
        deployer
      );

    const marketplace = await MarkerplaceFactory.deploy();

    await marketplace.deployed();

    console.log(
      `Marketplace with owner ${deployer.address} deployed to ${marketplace.address}`
    );

    console.log(taskArgs.account);
  });


task("create-nft", "Prints an account's balance")
  .addParam("marketplace", "The contract's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const MarkerplaceFactory = await hre.ethers.getContractFactory(
        "NFTMarketplace", 
        deployer
      );

    const marketplace = await MarkerplaceFactory.attach(taskArgs.marketplace);

    const tx = await marketplace.createNFT("Testt");
    const receipt = tx.wait();

    if(receipt.status === 0) {
        throw new Error("transaction failed");
    }

    console.log("NFT created");
  });

 task("claim", "Prints an account's balance")
  .addParam("marketplace", "The contract's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer, firstUser] = await hre.ethers.getSigners();
    const MarkerplaceFactory = await hre.ethers.getContractFactory(
        "NFTMarketplace", 
        deployer
      );

    const marketplace = await MarkerplaceFactory.attach(taskArgs.marketplace);

    const tx = await marketplace.createNFT("Testt");
    const receipt = tx.wait();

    if(receipt.status === 0) {
        throw new Error("transaction failed");
    }

    console.log("NFT created");

    const tx2 = await marketplace.listNFTForSale(taskArgs.marketplace, 0, 1);
    const receiptTwo = await tx2.wait();

    if(receiptTwo.status === 0) {
        throw new Error("transaction two failed");
    }


    const markerplaceFirstUser = marketplace.connect(firstUser);
    const tx3 = await markerplaceFirstUser.purchaseNFT(taskArgs.marketplace, 0, firstUser.address);
    const receiptThree = await tx3.wait();

    if(receiptThree.status === 0) {
        throw new Error("transaction 3 failed");
    }


    const tx4 = await marketplace.claimProfit();
    const receiptFour = await tx4.wait();

    if(receiptFour.status === 0) {
        throw new Error("transaction 4 failed");
    }

    console.log("Profit claimed");
  });
