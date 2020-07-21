const time = require("./Tools/time");
const breeding = artifacts.require("Breeding.sol");
const charactersNames = ["Character #1", "Character #2", "Breeding", "Bob's Character"];

contract("Breeding", (accounts) => {
	let [, alice, bob] = accounts;
	let contractInstance;
	let firstCharacter;
	let secondCharacter;

	beforeEach(async () => {
		contractInstance = await breeding.new();
		firstCharacter = await contractInstance.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
		assert.strictEqual(firstCharacter.receipt.status, true); 
        assert.strictEqual(firstCharacter.logs[0].args.name, charactersNames[0]);

		secondCharacter = await contractInstance.createRandomCharacter(charactersNames[1], {from: alice, value: 5000000000000000});
		assert.strictEqual(secondCharacter.receipt.status, true); 
        assert.strictEqual(secondCharacter.logs[0].args.name, charactersNames[1]);
	})

	afterEach(async () => {
		await contractInstance.kill();
	})

	it("should be able to breed two characters", async () => {
		await time.advanceTime(360);
		await time.advanceBlock();

		const characterFromBreeding = await contractInstance.crossBreeding(firstCharacter.logs[0].args.id.words[0], secondCharacter.logs[0].args.id.words[0], charactersNames[2], {from: alice});
		assert.strictEqual(characterFromBreeding.receipt.status, true);
		assert.strictEqual(characterFromBreeding.logs[0].args.name, charactersNames[2]);
	})

	it("should not be able to breed two characters when one or both of them aren't ready", async () => {
		try {
    	    await contractInstance.crossBreeding(firstCharacter.logs[0].args.id.words[0], secondCharacter.logs[0].args.id.words[0], charactersNames[2], {from: alice});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
		assert(false, "The contract did not throw an error");
	})
	
	it("should not be able to breed two characters with different owners", async() => {
		const characterOfAnotherOwner = await contractInstance.createRandomCharacter(charactersNames[3], {from: bob, value: 5000000000000000});
		assert.strictEqual(characterOfAnotherOwner.receipt.status, true); 
        assert.strictEqual(characterOfAnotherOwner.logs[0].args.name, charactersNames[3]);

		await time.advanceTime(360);
		await time.advanceBlock();

		try {
    	    await contractInstance.crossBreeding(firstCharacter.logs[0].args.id.words[0], characterOfAnotherOwner.logs[0].args.id.words[0], charactersNames[2], {from: alice});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
		assert(false, "The contract did not throw an error");
	})
	
})