const {ether, expectEvent, expectRevert, BN} = require("@openzeppelin/test-helpers");
const { assert } = require("hardhat");

const UserAddressList = artifacts.require("UserAddressList");

describe("UserAddressList contract", function () {
    let accounts;
    let admin;
    let aList;

    before(async function () {
        accounts = await web3.eth.getAccounts();
        admin = accounts[0];

        aList = await UserAddressList.new();
        await aList.initialize(admin);
    });

    it('should only init once', async function () {
        await expectRevert(aList.initialize(accounts[1]), "Already initialized");
    });

    describe("TODO(yqq) add test cases for UserAddressList.sol", async function () {
        let ok = true
        // TODO(yqq) add test cases for UserAddressList
        assert.isTrue(ok)
    })

});