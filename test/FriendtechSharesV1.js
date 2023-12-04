const FriendtechSharesV1 = artifacts.require("FriendtechSharesV1");
const TechSharesToken = artifacts.require("TechSharesToken"); // Assuming you have a separate contract for the token

contract("FriendtechSharesV1", (accounts) => {
  let friendtechShares;
  let techSharesToken;

  const owner = accounts[0];
  const partyA = accounts[1];
  const partyB = accounts[2];
  const partyC = accounts[3];
  const protocolFeeDestination = accounts[4];
  const buyer = accounts[5];

  before(async () => {
    techSharesToken = await TechSharesToken.new(); // Deploy your ERC20 token contract
    friendtechShares = await FriendtechSharesV1.new();
    await friendtechShares.setERC20TokenAddress(techSharesToken.address);
    await friendtechShares.setFeeDestination(protocolFeeDestination);
  });

  it("should allow buying shares", async () => {
    const initialBalance = await techSharesToken.balanceOf(buyer);

    // Assuming buyer approves the contract to spend tokens
    await techSharesToken.approve(friendtechShares.address, 1000, {
      from: buyer,
    });

    await friendtechShares.buyShares(accounts[8], 10, { from: buyer });

    const finalBalance = await techSharesToken.balanceOf(buyer);

    assert.equal(
      finalBalance.toNumber(),
      initialBalance.toNumber() - 10,
      "Buyer's token balance should be reduced by the purchase amount"
    );
  });

  it("should allow selling shares", async () => {
    // Assuming the seller has some shares to sell
    await techSharesToken.transfer(buyer, 10);
    await techSharesToken.approve(friendtechShares.address, 1000, {
      from: buyer,
    });

    const initialBalance = await techSharesToken.balanceOf(buyer);

    await friendtechShares.sellShares(accounts[8], 5, { from: buyer });

    const finalBalance = await techSharesToken.balanceOf(buyer);

    assert.equal(
      finalBalance.toNumber(),
      initialBalance.toNumber() + 5,
      "Buyer's token balance should be increased by the sell amount"
    );
  });
});
