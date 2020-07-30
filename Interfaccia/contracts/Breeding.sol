pragma solidity >0.6.0;

import "./Characters.sol";

contract Breeding is Characters {
    
    uint restoreTime = 1 days;
    
    ///@dev                 funzione che imposta il tempo di ripresa di un personaggio dopo il breeding
    ///@param _character    puntatore al personaggio da modificare
    function _triggerCooldownAfterBreeding(Character storage _character) private {
        _character.readyTime = uint32(now + restoreTime);
    }

    ///@dev                 funzione che controlla se il personaggio può essere utilizzato
    ///@param _character    puntatore al personaggio da modificare
    function _isReady(Character storage _character) private view returns (bool) {
        return (_character.readyTime <= now);
    }
    
    ///@dev                         funzione usata dal giocatore per creare un personaggio tramite il breeding
    ///@param id_first_character    l'id del primo personaggio
    ///@param id_second_character   l'id del secondo personaggio
    ///@param _newbornName          il nome scelto dal giocatore per il nuovo personaggio 
    function crossBreeding(uint id_first_character, uint id_second_character, string memory _newbornName) public {
        require(msg.sender == characterToOwner[id_first_character] && msg.sender == characterToOwner[id_second_character]); //controllo di proprietà dei due personaggi
        Character storage characterOne = book[id_first_character];
        Character storage characterTwo = book[id_second_character];
        
        require(_isReady(characterOne) && _isReady(characterTwo));
        
        _createCharacterFromBreeding(_newbornName, id_first_character, id_second_character); 
        
        _triggerCooldownAfterBreeding(characterOne);
        _triggerCooldownAfterBreeding(characterTwo);
    }
}