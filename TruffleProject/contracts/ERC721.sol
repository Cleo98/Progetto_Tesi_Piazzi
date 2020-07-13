pragma solidity >0.6.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Characters.sol";

abstract contract ERC721 is IERC721, Characters {
    
    mapping(uint => address) characterApprovals;
    
    //dato un address restituisce quanti characters esso possiede
    function balanceOf(address owner) external view override returns (uint256 balance) {
        return ownerCharacterCount[owner];
    }
    
    //dato un id la funzione restituisce l'indirizzo del proprietario a cui appartiene il token
    function ownerOf(uint256 tokenId) external view override returns (address owner) {
        return characterToOwner[tokenId];
    }

    //il proprietario del character chiama questa funzione con il suo indirizzo (from), l'indirizzo della persona
    //a cui vuole trasferire il token (to) e l'id del token che vuole mandare
    function transferFrom(address from, address to, uint256 tokenId) external override{
        require (characterToOwner[tokenId] == msg.sender || characterApprovals[tokenId] == msg.sender);
        ownerCharacterCount[to]++;
        ownerCharacterCount[from]--;
        characterToOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    //il proprietario del token chiama questa funzione con l'indirizzo a cui vuole dare l'approvazione e l'id del token che vuole consegnare
    //il ricevente chiama la funzione transferFrom con il token che vuole prendere 
    function approve(address to, uint256 tokenId) external override {
        require(msg.sender == characterToOwner[tokenId]);
        characterApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

}