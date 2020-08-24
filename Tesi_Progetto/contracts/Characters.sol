pragma solidity >=0.6.2 <0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Characters is Ownable, IERC721{

    uint cooldownTime = 5 minutes; //Character
    uint creationFee = 0.005 ether;
    uint restoreTime = 1 days; //Breeding
    //Minigames
    uint private randomNumber;
    uint restoreTimeM = 7 days;

    //events
    event NewCharacter(string name, uint id, uint rarity);
    event GameResults(uint playerGuess, uint result, uint v, uint xpVinti);
    event BonusGameResult(uint xpVinti);
    event LevelUp(uint idCharacter, uint level, uint xp);

    struct Character {
        string name;
        uint32 id;
        uint32 readyTime;
        uint16 xp;
        uint8 rarity;
        uint8 level; 
    }
    
    Character[] public book; 
    mapping (uint => address) public characterToOwner;
    mapping (address => uint) ownerCharacterCount;
    mapping(uint => address) characterApprovals;
    
    //*********************************CHARACTER***************************************************
    function _getArrayLength() private view returns(uint) {
        return book.length;
    }
    
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
    
    function _createNewCharacter(string memory _name, uint _id, uint _rarity) private {
        book.push(Character(_name, uint32(_id), uint32(now + cooldownTime * 1), 10, uint8(_rarity), 1));
        characterToOwner[_id] = msg.sender;  
        ownerCharacterCount[msg.sender]++; 
        emit NewCharacter(_name, _id, _rarity);
    }

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

    function createRandomCharacter(string calldata _name) external payable {
        require(ownerCharacterCount[msg.sender] < 2 && msg.value == creationFee);
        uint idCharacter = _getArrayLength();
        _createNewCharacter(_name, idCharacter, _generateRarity(idCharacter));
    }

    function setCreationFee(uint _fee) external onlyOwner {
        creationFee = _fee;
    }

    function withdraw() external onlyOwner {
        address payable _owner = address(uint160(owner()));
        _owner.transfer(address(this).balance);
    }

    function kill() public onlyOwner {
        address payable _owner = address(uint160(owner()));
        selfdestruct(_owner);
    }
    
    //*********************************BREEDING***************************************************
    function _isReady(Character storage _character) private view returns (bool) {
        return (_character.readyTime <= now);
    }

    function _triggerCooldownAfterBreeding(Character storage _character) private {
        _character.readyTime = uint32(now + restoreTime);
    }
    
    function createCharacterFromBreeding(string calldata _name, uint _firstId, uint _secondId) external {
        require(msg.sender == characterToOwner[_firstId] && msg.sender == characterToOwner[_secondId] && ownerCharacterCount[msg.sender] < 20); 
        Character storage characterOne = book[_firstId];
        Character storage characterTwo = book[_secondId];
                
        require(_isReady(characterOne) && _isReady(characterTwo));
        
        uint idCharacter = _getArrayLength();
        
        if((idCharacter % (_firstId + _secondId)) == 0){
            _createNewCharacter(_name, idCharacter, 5);
        }else{
            _createNewCharacter(_name, idCharacter, _generateRarity(idCharacter));
        }

        _triggerCooldownAfterBreeding(characterOne);
        _triggerCooldownAfterBreeding(characterTwo);
    }
    
    //*********************************MINIGAMES***************************************************    
    function _setRandomNumber(uint _number) external onlyOwner {
        randomNumber = _number;
    }

    function _triggerCooldown(Character storage _character) private {
        _character.readyTime = uint32(now + cooldownTime * _character.level);
    }
    
    function _triggerCooldownLevelTwenty(Character storage _character) private {
        _character.readyTime = uint32(now + restoreTimeM);
    }

    function _characterCheck(Character storage _character, uint _xpScommessi) private {
        require(_isReady(_character) && (_character.xp >= _xpScommessi) && (_xpScommessi > 0 || _xpScommessi <= 25) && (_character.level < 20));
        _character.xp -= uint16(_xpScommessi);
    }
    
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

    function _bonusRarity(uint _rarity, uint _characterRarity) private pure returns (uint) {
        if(_rarity == _characterRarity){
            return 2;
        }else{
            return 1;
        }
    }
    
    function _generateRandomDice(uint _str) private returns (uint) {
        return uint(keccak256(abi.encodePacked(_str, now, randomNumber++))) % 6 + 1;
    }

    function sumDice(uint _idCharacter, uint _guess, uint _xpScommessi) external {
        require(msg.sender == characterToOwner[_idCharacter]);
        Character storage player = book[_idCharacter];
        uint xp_iniziali = player.xp;
        _characterCheck(player, _xpScommessi);
        
        uint somma = _generateRandomDice(_idCharacter) + _generateRandomDice(_xpScommessi);
        
        if(_guess == somma){
            player.xp += uint16(_xpScommessi * 4 * _bonusXp(player.level) * _bonusRarity(5, player.rarity));
        }else if(_guess == somma - 1 || _guess == somma + 1) {
            player.xp +=uint16(_xpScommessi * 3);
        }else if(_guess == somma - 2 || _guess == somma + 2) {
            player.xp +=uint16(_xpScommessi * 2);
        }
        
        if(player.xp < xp_iniziali) {
            emit GameResults(_guess, somma, 0, _xpScommessi);
        }else{
            emit GameResults(_guess, somma, 1, player.xp - xp_iniziali);
        }
        
        _triggerCooldown(player);
    }
    
    function fightDice(uint _idCharacter, uint _xpScommessi) external {
        require(msg.sender == characterToOwner[_idCharacter]);
        Character storage player = book[_idCharacter];
        uint xp_iniziali = player.xp;
        _characterCheck(player, _xpScommessi);
        
        uint player_dice = _generateRandomDice(_idCharacter);
        uint enemy_dice = _generateRandomDice(_xpScommessi);
        
        if(player_dice > enemy_dice){
            player.xp += uint16(_xpScommessi * 2 * _bonusXp(player.level) * _bonusRarity(3, player.rarity));
        }else if (player_dice == enemy_dice){
            player.xp +=uint16(_xpScommessi);
        }
        
        if(player.xp < xp_iniziali) {
            emit GameResults(player_dice, enemy_dice, 0, _xpScommessi);
        }else{
            emit GameResults(player_dice, enemy_dice, 1, player.xp - xp_iniziali);
        }
                
        _triggerCooldown(player);
        
    }
    
    function pariDispari(uint _idCharacter, uint _guess, uint _xpScommessi) external {
        require(msg.sender == characterToOwner[_idCharacter]);
        Character storage player = book[_idCharacter];
        uint xp_iniziali = player.xp;
        _characterCheck(player, _xpScommessi);
        
        uint dice = _generateRandomDice(_idCharacter);
        
        if((dice % 2 == 0 && _guess % 2 == 0) || (dice % 2 == 1 && _guess % 2 == 1)){
            player.xp += uint16(_xpScommessi * 2 * _bonusXp(player.level) * _bonusRarity(2, player.rarity));
        }
        
        //se indovina anche il numero esatto del dado, ottiene un bonus ulteriore
        if(_guess == dice) {
            player.xp += uint16(_xpScommessi * 2 * _bonusRarity(2, player.rarity));
        }
        
        if(player.xp < xp_iniziali) {
            emit GameResults(_guess, dice, 0, _xpScommessi);
        }else{
            emit GameResults(_guess, dice, 1, player.xp - xp_iniziali);
        }
        
        _triggerCooldown(player);
    }
    
    function highLow(uint _idCharacter, uint _guess, uint _xpScommessi) external {
        require(msg.sender == characterToOwner[_idCharacter]);
        Character storage player = book[_idCharacter];
        uint xp_iniziali = player.xp;
        _characterCheck(player, _xpScommessi);
        
        uint dice = _generateRandomDice(_idCharacter);
        
        if((dice <= 3 && _guess <= 3) || (dice > 3 && _guess > 3)){
            player.xp += uint16(_xpScommessi * 3 * _bonusXp(player.level) * _bonusRarity(1, player.rarity));
        }
        
        //se indovina anche il numero esatto del dado, ottiene un bonus ulteriore
        if(_guess == dice) {
            player.xp += uint16(_xpScommessi * 2 * _bonusXp(player.level));
        }
        
        if(player.xp < xp_iniziali) {
            emit GameResults(_guess, dice, 0, _xpScommessi);
        }else{
            emit GameResults(_guess, dice, 1, player.xp - xp_iniziali);
        }
        
        _triggerCooldown(player);
    }
    
    function emergencyGame(uint _idCharacter) external {
        require(msg.sender == characterToOwner[_idCharacter]);
        Character storage player = book[_idCharacter];
        require(_isReady(player) && player.xp == 0);
        
        uint xps = uint(keccak256(abi.encodePacked(_idCharacter, now, randomNumber++)));
        
        if (xps % 499 == 0){
            player.xp += 20;
        }else if(xps % 7 == 0){
            player.xp += 10;
        }else{
            player.xp += 5;
        }
        
        emit BonusGameResult(player.xp);
    }
    
    function xpGiveAway(uint _firstId, uint _secondId) external {
        require(msg.sender == characterToOwner[_firstId] && msg.sender == characterToOwner[_secondId]);
        Character storage characterOne = book[_firstId];
        Character storage characterTwo = book[_secondId];
        
        require(_isReady(characterOne) && _isReady(characterTwo));
        require(characterOne.level < 20 || characterTwo.level == 20);
        
        characterOne.xp += uint16(uint(keccak256(abi.encodePacked(_secondId, now, randomNumber++))) % 100 + 1);
        
        emit BonusGameResult(characterOne.xp);
        
        _triggerCooldownLevelTwenty(characterTwo);
        _triggerCooldown(characterOne);
    }

    //*********************************LABORATORY***************************************************
    modifier checkLevel(uint _level, uint _id) {
        require(book[_id].level < _level);
        _;
    }
    
    function _hasEnoughXp(Character storage _character) private view returns (bool){
        return (_character.xp >= 1500 * _character.level);
    }

    function _evolutionTime(Character storage _character) private {
        uint time = 3 hours;
        _character.readyTime = uint32(now + time * _character.rarity * _character.level);
    }

    function upgradeCharacter(uint _idCharacter) external checkLevel(20, _idCharacter) {
        require(msg.sender == characterToOwner[_idCharacter]);
        Character storage char = book[_idCharacter];
        require(_hasEnoughXp(char));
        
        uint xp_nuovi = 5;
        
        if(char.xp > 1500 * char.level){
            xp_nuovi = char.xp - 1500 * char.level;
        }
        
        char.level += 1; 
        char.xp = uint16(xp_nuovi);

        emit LevelUp(_idCharacter, char.level, char.xp);
        
        _evolutionTime(char);
    }

    function changeXp(uint _idCharacter, uint _xp) public onlyOwner {
        Character storage char = book[_idCharacter];
        char.xp += uint16(_xp); 
    }
    
    //*********************************DONAZIONE***************************************************
    function balanceOf(address owner) external view override returns (uint256 balance) {
        return ownerCharacterCount[owner];
    }
    
    function ownerOf(uint256 tokenId) external view override returns (address) {
        return characterToOwner[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) external override{
        require (characterToOwner[tokenId] == msg.sender || characterApprovals[tokenId] == msg.sender && ownerCharacterCount[to] < 20);
        ownerCharacterCount[to]++;
        ownerCharacterCount[from]--;
        characterToOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external override {
        require(msg.sender == characterToOwner[tokenId]);
        characterApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view override returns (address operator) {
        return operator; //address(uint160(0));
    }
    
    function isApprovedForAll(address owner, address operator) external view override returns (bool){
        return false;
    }
   
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        //uint x = 0;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override{
        //uint x = 0;
    }
    
    function setApprovalForAll(address operator, bool _approved) external override{
        //uint x = 0;
    }

    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return false;
    }
}