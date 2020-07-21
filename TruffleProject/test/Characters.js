//J// CONST serve a dichiarare una costante, cioè una variaibile che non può essere riassegnata. Lo scope è limitato al blocco e vale l'hoisting
//Questa funzione restituisce una "contract abstraction", che nasconde la complessità di interazione con Ethereum
const characters = artifacts.require("Characters.sol");
const charactersNames = ["Character #1", "Character #2", "Character #3"]; //per rendere più leggero il codice
var assert = require('chai').assert

/*J// Una FUNZIONE ASINCRONA non blocca il nostro codice JS. In altre parole se eseguiamo una funzione asincrona, questa lavorerà nel background
	  del programma principale. In questo modo possiamo usare funzioni pesanti che possono impiegare tanto tempo, senza bloccare altri eventi JavaScript.
	  Le funzioni in JavaScript sono veri e propri oggetti, per cui si può passare una funzione come parametro di un'altra funzione.
	  Le FUNZIONI ANONIME sono funzioni dichiarate nello stesso momento in cui vengono utilizzate.
	  Quando passiamo una funzione come parametro, possiamo anche specificare con precisione in che momento mandarla in esecuzione.
	  Le ARROW FUNCTION sono funzioni anonime con una sintassi molto concisa e alcune caratterisitche specifiche. 
	  In particolare, (p1, p2...) => {istruzioni} 
	  Sono molto usate nelle callback perchè allegeriscono il codice.*/
//contract(string contrattoDaTestare, callback)
//it(string descrizioneTest, callback)
contract("Characters", (accounts) => { //accounts permette di accedere agli account di testing di Ganache ad esempio
	//J// LET serve per dichiarare delle variabili solitamente con scope locale e vale l'hoisting (non possono essere usate prima di essere dichiarate)
	let [, alice, bob] = accounts; //in questo modo il codice è più semplice da leggere, al contrario di account[0]....
	let contractInstace;

	//questa funzione permette di creare un HOOK da eseguire prima di qualsiasi test presente
	beforeEach(async () => {
		//per poter interagire con lo smart contract è necessario creare un oggetto in JavaScript che si comporterà come un'istanza del contratto
		contractInstace = await characters.new();
	})

	afterEach(async () => {
		await contractInstace.kill();
	})

	//Questo test mostra come sia equivalente utilizzare assert di Node.js oppure Chai. La differenza sta nella "leggibilità" del codice
	it("should be able to create two characters", async () => {
		/*J// AWAIT è un operatore che mette in pausa una funzione asincrona fino a quando una Promise non ha finito il suo lavoro. 
			  Dopodichè fa riprendere l'esecuzione della funzione asincrona. A seconda dell'esito della Promise, l'espressione di await 
			  può rilasciare un fulfilled or rejected value.
			  Una PROMISE è un oggetto che rappresenta il successo o il fallimento di un'operazione asincrona. */
		//chiamo la funzione per creare un personaggio e specifico quale utente la vuole utilizzare 
		const result = await contractInstace.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
		
		//Truffle provvede a fornire i logs generati dallo smart contract 
		//Le ASSERT functions provvedono a testare una condizione semplice e, in caso di incongruenze, lanciano un errore
		assert.strictEqual(result.receipt.status, true); //true indica che la transazione ha avuto successo
        assert.strictEqual(result.logs[0].args.name, charactersNames[0]);

        const resultTwo = await contractInstace.createRandomCharacter(charactersNames[1], {from: alice, value: 5000000000000000});
        expect(resultTwo.receipt.status).to.equal(true);
        expect(resultTwo.logs[0].args.name).to.equal(charactersNames[1]);
	})

	it("should not allow to create more than 2 characters", async () => {
		const result = await contractInstace.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
		assert.strictEqual(result.receipt.status, true); 
        assert.strictEqual(result.logs[0].args.name, charactersNames[0]);
        
        const resultTwo = await contractInstace.createRandomCharacter(charactersNames[1], {from: alice, value: 5000000000000000});
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
