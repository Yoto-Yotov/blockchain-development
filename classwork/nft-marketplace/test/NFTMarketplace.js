const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("NFTMarketplace", function () {
  let markerplaceFirstUser, deployer, firstUser, secondUser;

  this.beforeAll(async function () {
    [deployer, firstUser, secondUser] = await ethers.getSigners();
    const {marketplace} = await loadFixture(deployAndMint);
    markerplaceFirstUser = getFirstUserMarketplace(marketplace, firstUser);
  })

  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAndMint() {
    const MarkerplaceFactory = await ethers.getContractFactory(
      "NFTMarketplace", 
      deployer
    );

    const marketplace = await MarkerplaceFactory.deploy();

    const _marketplaceFirstUser = marketplace.connect(firstUser);

    await _marketplaceFirstUser.createNFT("ttest");

    return { marketplace, deployer, firstUser };
  }

  async function list() {
    const { marketplace } = await loadFixture(deployAndMint);
    const price = ethers.utils.parseEther("1");
    await markerplaceFirstUser.approve(marketplace.address, 0);
    await markerplaceFirstUser.listNFTForSale(marketplace.address, 0, price);

    return { marketplace };
  }

  describe("Listing", function () {
    it("reverts when price == 0", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      await expect(
        marketplace.listNFTForSale(marketplace.address, 0, 0)
      ).to.be.revertedWith("Price must be greater than 0");
    });

    it("reverts when already listed", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      const price = ethers.utils.parseEther("1");
      await markerplaceFirstUser.approve(marketplace.address, 0);
      await markerplaceFirstUser.listNFTForSale(marketplace.address, 0, price);

      await expect(
        marketplace.listNFTForSale(marketplace.address, 0, price)
      ).to.be.revertedWith("NFT already listed for sale");

    });

    it("should succed", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      const price = ethers.utils.parseEther("1");
      await markerplaceFirstUser.approve(marketplace.address, 0);

      await expect(
        markerplaceFirstUser.listNFTForSale(marketplace.address, 0, price)
      ).to.emit(marketplace, "NFTListed").withArgs(marketplace.address, 0, price);

    });

  });  
  
  describe("Purchase", function () {
    it("reverts when not listed for sale", async function () {
      const { marketplace, deployer } = await loadFixture(deployAndMint);

      await expect(
        marketplace.purchaseNFT(marketplace.address, 0, secondUser.address)
      ).to.be.revertedWith("NFT not listed for sale");
    });
  
    it("reverts when price is not correct", async function () {
      const { marketplace, deployer } = await loadFixture(list);

      await expect(
        marketplace.purchaseNFT(marketplace.address, 0, secondUser.address, {value: ethers.utils.parseEther("2")})
      ).to.be.revertedWith("Incorect price");
    });


    it("succeeds", async function () {
      const { marketplace, deployer } = await loadFixture(list);

      await marketplace.purchaseNFT(marketplace.address, 0, secondUser.address, {value: ethers.utils.parseEther("1")})

      expect((await marketplace.nftSale(marketplace.address, 0)).price).to.equal(0);
      expect(await marketplace.ownerOf(0)).to.be.equal(secondUser.address);
    });
    
  });

});


function getFirstUserMarketplace(marketplace, firstUser) {
  return marketplace.connect(firstUser);
}
