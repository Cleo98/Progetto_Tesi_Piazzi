const characters = artifacts.require("Characters.sol");
const charactersNames = ["Character #1", "Character #2", "Character #3"]; 
var assert = require('chai').assert

contract("Characters", (accounts) => { 
	let [, alice, bob] = accounts; 
	let contractInstance;

	beforeEach(async () => {
		contractInstance = await characters.new();
	})

	afterEach(async () => {
		await contractInstance.kill();
	})

	it("should be able to create two characters", async () => {
		const result = await contractInstance.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
		assert.strictEqual(result.receipt.status, true); 
        	assert.strictEqual(result.logs[0].args.name, charactersNames[0]);

        	const resultTwo = await contractInstance.createRandomCharacter(charactersNames[1], {from: alice, value: 5000000000000000});
        	expect(resultTwo.receipt.status).to.equal(true);
        	expect(resultTwo.logs[0].args.name).to.equal(charactersNames[1]);
	})

	it("should not allow to create more than 2 characters", async () => {
		const result = await contractInstance.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
		assert.strictEqual(result.receipt.status, true); 
        	assert.strictEqual(result.logs[0].args.name, charactersNames[0]);
        
        	const resultTwo = await contractInstance.createRandomCharacter(charactersNames[1], {from: alice, value: 5000000000000000});
		assert.strictEqual(resultTwo.receipt.status, true); 
        	assert.strictEqual(resultTwo.logs[0].args.name, charactersNames[1]);
   
        try {
    	    await contractInstance.createRandomCharacter(charactersNames[2], {from: alice, value: 5000000000000000});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
		assert(false, "The contract did not throw an error");
	})
})
