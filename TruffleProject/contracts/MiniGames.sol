pragma solidity >0.6.0;

import "./Characters.sol";

contract MiniGames is Characters {
    
    event GameResults(uint id, uint playerGuess, uint result, uint xpScommessi, uint xpTotali);
    event BonusGameResult(uint id, uint xpTotali);
    
    uint private randomNumber;
    uint restoreTime = 7 days;
    
    ///@dev         controlla che il personaggio che il giocatore vuole utilizzare sia di sua proprietà
    ///@param _id   l'id del personaggio 
    modifier ownership(uint _id) {
        require(msg.sender == characterToOwner[_id]);
        _;
    }
    
    ///@dev             funzione per settare la variabile randomNumber
    ///@param _number   un numero
    function _setRandomNumber(uint _number) private onlyOwner {
        randomNumber = _number;
    }

    ///@dev                 funzione che controlla che il personaggio sia pronto all'utilizzo 
    ///@param _character    il puntatore al personaggio
    function _isReady(Character storage _character) private view returns (bool) {
        return (_character.readyTime <= now);
    }
    
    ///@dev                 funzione che imposta il tempo di ripresa del personaggio dopo essere stato utilizzato 
    ///@param _character    il puntatore al personaggio
    function _triggerCooldown(Character storage _character) private {
        _character.readyTime = uint32(now + cooldownTime * _character.level);
    }
    
    ///@dev                 funzione che imposta il tempo di ripresa di un personaggio di livello 20 dopo essere stato utilizzato 
    ///@param _character    il puntatore al personaggio
    function _triggerCooldownLevelTwenty(Character storage _character) private {
        _character.readyTime = uint32(now + restoreTime);
    }

    ///@dev                 funzione che controlla il personaggio prima del gioco  
    ///@param _character    il puntatore al personaggio
    ///@param _xpScommessi  numero di xp scommessi dal giocatore
    function _characterCheck(Character storage _character, uint _xpScommessi) private {
        require(_isReady(_character) && (_character.xp > _xpScommessi) && (_xpScommessi > 0 || _xpScommessi <= 25));
        _character.xp -= uint16(_xpScommessi);
    }
    
    ///@dev             funzione che assegna un moltiplicatore extra (in caso di vincita) a seconda del livello
    ///@param _level    livello del personaggio
    function _bonusXp(uint _level) private pure returns (uint) {
        if(_level >= 5 && _level < 10){
            return 2;
        }else if(_level >= 10 && _level < 15) {
            return 3;
        }else if(_level >= 15 && _level <20) {
            return 4;
        }else{
            return 1;
        }
    }
    
    ///@dev                     funzione che determina un moltiplicatore extra (in caso di vincita) a seconda della rarità
    ///@param _rarity           parametro fisso che indica una specifica rarità
    ///@param _characterRarity  rarità del personaggio scelto dal giocatore
    function _bonusRarity(uint _rarity, uint _characterRarity) private pure returns (uint) {
        if(_rarity == _characterRarity){
            return _rarity * 2;
        }else{
            return 1;
        }
    }
    
    ///@dev         funzione che genera un dado pseudocasuale 
    ///@param _str  un valore che contribuisce alla creazione del dado
    function _generateRandomDice(uint _str) private returns (uint) {
        return uint(keccak256(abi.encodePacked(_str, now, randomNumber++))) % 6 + 1;
    }
    
    ///@dev                 il primo gioco prevede che il giocatore debba indovinare la somma di due dadi 
    ///                     se viene usato un personaggio di rarità 5 si ottiene un bonus
    ///@param _idCharacter  l'id del personaggio scelto
    ///@param _guess        il risultato della somma secondo il giocatore
    ///@param _xpScommessi  la quantità di xp scommessi dal giocatore
    function sumDice(uint _idCharacter, uint _guess, uint _xpScommessi) public ownership(_idCharacter) {
        Character storage player = book[_idCharacter];
        _characterCheck(player, _xpScommessi);
        
        uint somma = _generateRandomDice(_idCharacter) + _generateRandomDice(_xpScommessi);
        
        if(_guess == somma){
            player.xp += uint16(_xpScommessi * 4 * _bonusXp(player.level) * _bonusRarity(5, player.rarity));
        }else if(_guess == somma - 1 || _guess == somma + 1) {
            player.xp +=uint16(_xpScommessi * 3);
        }else if(_guess == somma - 2 || _guess == somma + 2) {
            player.xp +=uint16(_xpScommessi * 2);
        }
        
        emit GameResults(_idCharacter, _guess, somma, _xpScommessi, player.xp);
        
        _triggerCooldown(player);
    }
    
    ///@dev                 il gioco prevede che vengano generati due dadi: uno viene assegnato al giocatore mentre l'altro all'avversario (computer). 
    ///                     Vince il numero più alto
    ///                     se viene usato un personaggio di rarità 3 si ottiene un bonus
    ///@param _idCharacter  l'id del personaggio scelto
    ///@param _xpScommessi  la quantità di xp scommessi dal giocatore
    function fightDice(uint _idCharacter, uint _xpScommessi) public ownership(_idCharacter){
        Character storage player = book[_idCharacter];
        _characterCheck(player, _xpScommessi);
        
        uint player_dice = _generateRandomDice(_idCharacter);
        uint enemy_dice = _generateRandomDice(_xpScommessi);
        
        if(player_dice > enemy_dice){
            player.xp += uint16(_xpScommessi * 2 * _bonusXp(player.level) * _bonusRarity(3, player.rarity));
        }else if (player_dice == enemy_dice){
            player.xp +=uint16(_xpScommessi);
        }
        
        emit GameResults(_idCharacter, player_dice, enemy_dice, _xpScommessi, player.xp);
        
        _triggerCooldown(player);
        
    }
    
    ///@dev                 il giocatore deve indovinare se il dado generato sarà pari o dispari 
    ///                     se viene usato un personaggio di rarità 2 si ottiene un bonus
    ///@param _idCharacter  l'id del personaggio scelto
    ///@param _guess        il numero del dado che uscirà secondo il giocatore 
    ///@param _xpScommessi  la quantità di xp scommessi dal giocatore
    function pariDispari(uint _idCharacter, uint _guess, uint _xpScommessi) public ownership(_idCharacter) {
        Character storage player = book[_idCharacter];
        _characterCheck(player, _xpScommessi);
        
        uint dice = _generateRandomDice(_idCharacter);
        
        if((dice % 2 == 0 && _guess % 2 == 0) || (dice % 2 == 1 && _guess % 2 == 1)){
            player.xp += uint16(_xpScommessi * 2 * _bonusXp(player.level) * _bonusRarity(2, player.rarity));
        }
        
        //se indovina anche il numero esatto del dado, ottiene un bonus ulteriore
        if(_guess == dice) {
            player.xp += uint16(_xpScommessi * 2 * _bonusRarity(2, player.rarity));
        }
        
        emit GameResults(_idCharacter, _guess, dice, _xpScommessi, player.xp);
        
        _triggerCooldown(player);
    }
    
    ///@dev                 il giocatore deve indovinare se il dado generato sarà maggiore o minore di 3 
    ///                     se viene usato un personaggio di rarità 1 si ottiene un bonus
    ///@param _idCharacter  l'id del personaggio scelto
    ///@param _guess        il numero del dado che uscirà secondo il giocatore 
    ///@param _xpScommessi  la quantità di xp scommessi dal giocatore
    function highLow(uint _idCharacter, uint _guess, uint _xpScommessi) public ownership(_idCharacter) {
        Character storage player = book[_idCharacter];
        _characterCheck(player, _xpScommessi);
        
        uint dice = _generateRandomDice(_idCharacter);
        
        if((dice <= 3 && _guess <= 3) || (dice > 3 && _guess > 3)){
            player.xp += uint16(_xpScommessi * 3 * _bonusXp(player.level) * _bonusRarity(1, player.rarity));
        }
        
        //se indovina anche il numero esatto del dado, ottiene un bonus ulteriore
        if(_guess == dice) {
            player.xp += uint16(_xpScommessi * 2 * _bonusXp(player.level));
        }
        
        emit GameResults(_idCharacter, _guess, dice, _xpScommessi, player.xp);
        
        _triggerCooldown(player);
    }
    
    ///@dev                 qualora il personaggio dovesse rimanere senza xp, il giocatore potrà usare questa funzione per ricaricare il personaggio 
    ///@param _idCharacter  l'id del personaggio scelto
    function emergencyGame(uint _idCharacter) public ownership(_idCharacter) {
        Character storage player = book[_idCharacter];
        require(_isReady(player) && player.xp == 0);
        
        uint xps = uint(keccak256(abi.encodePacked(_idCharacter)));
        
        if (xps % 499 == 0){
            player.xp += 20;
        }else if(xps % 7 == 0){
            player.xp += 10;
        }else{
            player.xp += 5;
        }
        
        emit BonusGameResult(_idCharacter, player.xp);
    }
    
    ///@dev                 funzione che permette ad un personaggio di livello 20 di far guadagnare ad un altro personaggio un po' di xp
    ///@param _firstId      l'id del personaggio con un livello minore di 20
    ///@param _secondId     l'id del personaggio di livello 20
    function xpGiveAway(uint _firstId, uint _secondId) public ownership(_firstId) ownership(_secondId) {
        Character storage characterOne = book[_firstId];
        Character storage characterTwo = book[_secondId];
        
        require(_isReady(characterOne) && _isReady(characterTwo));
        require(characterOne.level < 20 || characterTwo.level == 20);
        
        characterOne.xp += uint16(_secondId % 100 + 1);
        
        emit BonusGameResult(_firstId, characterOne.xp);
        
        _triggerCooldownLevelTwenty(characterTwo);
        _triggerCooldown(characterOne);
    }
    
}