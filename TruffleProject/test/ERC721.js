const token = artifacts.require("ERC721.sol");
const charactersNames = ["Character #1"];

contract("ERC721", (accounts) => { 
    let [, alice, bob] = accounts; 
    let contractInstance;
    let aliceCharacter;
    let aliceCharacterId;

    beforeEach(async () => {
        contractInstance = await token.new();
        aliceCharacter = await contractInstance.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
        aliceCharacterId = aliceCharacter.logs[0].args.id.words[0];
    })

    afterEach(async () => {
        await contractInstance.kill();
    })

    context("single-step transfer scenario", async () => {
        it("should transfer a character", async () => {
            await contractInstance.transferFrom(alice, bob, aliceCharacterId, {from: alice});
            const newOwner = await contractInstance.ownerOf(aliceCharacterId);
            assert.equal(newOwner, bob);
        })
    })

    context("two-step transfer scenario", async () => {
        it("should approve and then transfer a character when the approved address calls transferForm", async () => {
            await contractInstance.approve(bob, aliceCharacterId, {from: alice});
            await contractInstance.transferFrom(alice, bob, aliceCharacterId, {from: bob});
            const newOwner = await contractInstance.ownerOf(aliceCharacterId);
            assert.equal(newOwner,bob);
        })

        it("should approve and then transfer a character when the owner calls transferForm", async () => {
            await contractInstance.approve(bob, aliceCharacterId, {from: alice});
            await contractInstance.transferFrom(alice, bob, aliceCharacterId, {from: alice});
            const newOwner = await contractInstance.ownerOf(aliceCharacterId);
            assert.equal(newOwner,bob);
        })
    })
})