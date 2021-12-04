pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract BluBoyX is ERC1155 {
    address creator;
    mapping (address => uint256) userList;
    uint256 public _tokens;
    uint256 private _price;
    uint256 public _total;
    string public name;
    string public symbol;
    
    constructor() public ERC1155('https://ipfs.io/ipfs/Qmex7bQqs5vW4nKgtBzcygAPcuvxWHyh9NgrsF2QC6mUcV/{id}.json') {
        creator = msg.sender;
        name = "BluWorld";
        symbol = "BBX";
        _tokens = 4994;
        _total = 5000;
        _price = 0.001 ether;

    }

    function mint(uint256 count ) payable public {
        
        require(_tokens > 0, "out of NFTs");
        creator.call{value: count * _price}("");
    
        for(uint256 i = 0; i < count; i++){
            _mint(msg.sender, _total - _tokens - 6, 1, "");
            _tokens--;
        }

        if(userList[msg.sender] > 0){
            userList[msg.sender] += count;
        }else {
            userList[msg.sender] = count;
        }
        
    }

    function tokensCount() public view returns (uint256) { 
        return _tokens;
    }

    function userHaveTokens(address _address) public view returns (uint256) { 
        return userList[_address];
    }

}