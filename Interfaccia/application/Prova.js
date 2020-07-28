import Web3 from 'web3';

class App {
	async component(){
		const metamaskInstalled = typeof window.web3 !== 'undefined'
		console.log("hello");
		console.log(metamaskInstalled);
	}
}