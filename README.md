# Progetto_Tesi_Piazzi - Sviluppo di un gioco su blockchain Ethereum utilizzando Solidity e Web3.js

Scopo del gioco: far raggiungere il massimo livello a ciascun personaggio

Meccanica del gioco:
 - Nella fase iniziale, il giocatore crea due personaggi con determinate caratteristiche iniziali.
 - Il giocatore può utilizzare i propri personaggi nella sezione "Minigiochi" per accumulare gli xp necessari per farli aumentare di livello.
 - I personaggi possono anche essere utilizzati all'interno della sezione di "Breeding" per dare vita ad un nuovo personaggio. 
 - I giocatori possono scambiarsi fra loro i personaggi.
 
Caratteristiche del gioco:
 - 4 tipologie (rarity) di personaggi diverse ciascuno con un'abilità speciale in ogni minigioco e un tempo di ripresa;
 - il livello massimo di ciascun personaggio è 20;
 - 4 minigiochi basati sul gambling pseudocasuale, 1 minigioco di emergenza (da utilizzare quando il personaggio non ha più xp) e 1 minigioco di collaborazione reciproca fra personaggi.
 
Nella cartella TruffleProject/contracts:
 - ERC721.sol: contiene le funzioni per gestire il token ERC721
 - Characters.sol: contiene tutte le funzioni necessarie per creare un nuovo personaggio
 - Breeding.sol: contiene le funzioni necessarie per creare un personaggio combinando due personaggi in possesso del giocatore
 - MiniGames.sol: contiene le funzioni con i minigiochi che permettono al personaggio di accumulare xp
 - Laboratory.sol: contiene le funzioni necessarie per far aumentare di livello un personaggio 
 
Breeding.sol, MiniGames.sol, Laboratory.sol sono sottoclassi di Characters.sol

Characters.sol è sottoclasse di ERC721.sol
