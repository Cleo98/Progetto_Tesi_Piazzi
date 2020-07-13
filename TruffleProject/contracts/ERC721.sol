pragma solidity >0.6.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Characters.sol";

abstract contract ERC721 is IERC721, Characters {
    
    mapping(uint => address) characterApprovals;
    
    function balanceOf(address owner) external view override returns (uint256 balance) {
        return ownerCharacterCount[owner];
    }
    
    function ownerOf(uint256 tokenId) external view override returns (address owner) {
        return characterToOwner[tokenId];
    }
    
    function transferFrom(address from, address to, uint256 tokenId) external override{
        require (characterToOwner[tokenId] == msg.sender || characterApprovals[tokenId] == msg.sender);
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

}
