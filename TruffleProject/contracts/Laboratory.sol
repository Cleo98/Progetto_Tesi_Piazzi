pragma solidity >0.6.0;

import "./Characters.sol";

contract Laboratory is Characters {
    
    modifier checkLevel(uint _level, uint _id) {
        require(book[_id].level < _level);
        _;
    }
    
    ///@dev                 funzione che controlla se il personaggio ha abbastanza xp per essere promosso al livello superiore
    ///@param _character    il riferimento al personaggio
    function _hasEnoughXp(Character storage _character) private view returns (bool){
        return (_character.xp >= 1500 * _character.level);
    }
    
    ///@dev                 funzione che imposta il tempo necessario per l'evoluzione
    ///@param _character    il riferimento al personaggio
    function _evolutionTime(Character storage _character) private {
        uint time = 2 hours;
        _character.readyTime = uint32(now + time * _character.rarity * _character.level);
    }
    
    ///@dev                 funzione che permette di promuovere un personaggio al livello successivo
    ///@param _idCharacter  l'id del personaggio da promuovere
    function upgradeCharacter(uint _idCharacter) public checkLevel(20, _idCharacter) {
        require(msg.sender == characterToOwner[_idCharacter]);
        Character storage char = book[_idCharacter];
        require(_hasEnoughXp(char));
        
        uint xp_nuovi = 5;
        
        if(char.xp > 100 * char.level){
            xp_nuovi = char.xp - 100 * char.level;
        }
        
        char.level += 1; 
        char.xp = uint16(xp_nuovi);
        
        _evolutionTime(char);
    }
}