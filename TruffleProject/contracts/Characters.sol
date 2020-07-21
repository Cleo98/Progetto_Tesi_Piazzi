pragma solidity >0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Characters is Ownable {
    
    event NewCharacter(string name, uint id, uint xp, uint rarity, uint level);
    
    uint cooldownTime = 5 minutes;
    uint creationFee = 0.005 ether; //attualmente equivale a 1 euro
    
    struct Character {
        string name;
        uint32 id;
        uint32 readyTime;
        uint16 xp;
        uint8 rarity;
        uint8 level; 
    }
    
    Character[] public book; //raccolta di tutti i personaggi creati 
    
    //contiene l'associazione (id personaggio) - (indirizzo proprietario) 
    mapping (uint => address) public characterToOwner;
    
    //contiene l'associazione (indirizzo giocatore) - (numero di personaggi posseduti)
    mapping (address => uint) ownerCharacterCount;
    
    ///@dev         funzione che restituisce la lunghezza dell'array dinamico "book"
    function _getArrayLength() private view returns(uint) {
        return book.length;
    }
    
    ///@dev          funzione che genera casualmente la rarità del personaggio 
    ///@param _id    l'id univoco del personaggio
    ///@return rare  il valore che determina la rarità del personaggio
    function _generateRarity(uint _id) private pure returns(uint) {
        uint rare = 1;
        uint count = 2;
        
        while(count<=5) {
            if(_id % count == 0){
                rare = count;
                return rare;
            }
            count += 1; 
        }
        
        return rare;
    }
    
    ///@dev             la funzione inizializza gli attributi del personaggio 
    ///@param _name     il nome che il giocatore sceglie per il proprio personaggio
    ///@param _id       l'id univoco del personaggio
    ///@param _rarity   il valore che determina la rarità del personaggio
    function _createNewCharacter(string memory _name, uint _id, uint _rarity) private {
        book.push(Character(_name, uint32(_id), uint32(now + cooldownTime * 1), 10, uint8(_rarity), 1));
        characterToOwner[_id] = msg.sender; //associa l'id del personaggio all'indirizzo con cui è stato creato 
        ownerCharacterCount[msg.sender]++; //aumenta la quantità di personaggi in possesso per un tale indirizzo
        emit NewCharacter(_name, _id, 10, _rarity, 1);
    }
    
    ///@dev             funzione che permette al giocatore di creare un personaggio a partire da due personaggi in suo possesso
    ///@param _name     il nome che il giocatore sceglie per il proprio per il proprio personaggio
    ///@param _firstId  l'id del primo personaggio scelto per il breeding 
    ///@param _secondId l'id del secondo personaggio scelto per il breeding
    function _createCharacterFromBreeding(string memory _name, uint _firstId, uint _secondId) internal {
        uint idCharacter = _getArrayLength();
        
        if((idCharacter % (_firstId + _secondId)) == 0){
            _createNewCharacter(_name, idCharacter, 5);
        }else{
            _createNewCharacter(_name, idCharacter, _generateRarity(idCharacter));
        }
    }
    
    ///@dev             funzione che permette al giocatore di creare un personaggio
    ///@dev             NOTA: questa funzione può essere chiamata solo due volte (sono necessari almeno due personaggi per poter usare tutte le funzioni)
    ///@param _name     il nome che il giocatore sceglie per il proprio personaggio
    function createRandomCharacter(string calldata _name) external payable {
        require(ownerCharacterCount[msg.sender] < 2);
        require(msg.value == creationFee);
        uint idCharacter = _getArrayLength();
        _createNewCharacter(_name, idCharacter, _generateRarity(idCharacter));
    }
    
    ///@dev     funzione che permette al proprietario del contratto di trasferire i fondi depositati dai giocatori al proprio account 
    function withdraw() external onlyOwner {
        address payable _owner = address(uint160(owner()));
        _owner.transfer(address(this).balance);
    }

    ///@dev     funzione che permette al proprietario del contratto di modificare il prezzo per creare un personaggio 
    function setCreationFee(uint _fee) external onlyOwner {
        creationFee = _fee;
    }
    
    ///@dev             funzione che permette di visualizzare la lista dei personaggi associati ad un certo indirizzo 
    ///@param _owner    l'inidirizzo di un giocatore
    ///@return result   restituisce un array contenente la lista dei personaggi associati ad un indirizzo
    function getCharactersByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerCharacterCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < book.length; i++) {
            if (characterToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function kill() public onlyOwner {
    	address payable _owner = address(uint160(owner()));
    	selfdestruct(_owner);
    }

}