// SPDX-License-Identifier: MIT
// SavageSnowmen v0.1
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "./rarible/royalties/contracts/LibPart.sol";
import "./rarible/royalties/contracts/LibRoyaltiesV2.sol";

contract SavageSnowmen is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Pausable,
    Ownable,
    RoyaltiesV2Impl
{
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256 private _price;
    uint96 private _percentBasisPoints;

    string private _tokenBaseURI;

    address payable private _treasuryWallet;
    address payable private _royaltiesWallet;

    uint256 public _cap;

    mapping(uint256 => string) public tokenIdToTokenURI;
    mapping(uint256 => address) public tokenToMinter;

    constructor(
        string memory name,
        string memory symbol,
        string memory tokenBaseURI,
        uint256 mintPrice,
        uint256 cap,
        address payable treasuryWallet,
        address payable royaltiesWallet
    ) ERC721(name, symbol) {
        _price = mintPrice;
        _cap = cap;
        _tokenBaseURI = tokenBaseURI;
        _treasuryWallet = treasuryWallet;
        _royaltiesWallet = royaltiesWallet;
        _percentBasisPoints = 0;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /// @inheritdoc	ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _tokenBaseURI = uri;
    }

    function setRoyaltiesWallet(address payable wallet) external onlyOwner {
        _royaltiesWallet = wallet;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _tokenBaseURI;
    }

    function tokenMinter(uint256 tokenId) public view returns (address) {
        return tokenToMinter[tokenId];
    }

    function mint(uint256 amount) public payable whenNotPaused {
        require(
            msg.value == _price * amount,
            "SavageSnowmen: invalid amount sent"
        );
        require(
            _tokenIdCounter.current() + amount <= _cap,
            "SavageSnowmen: supply too low to mint amount"
        );

        for (uint256 x = 0; x < amount; x++) {
            _safeMint(msg.sender, _tokenIdCounter.current());
            tokenToMinter[_tokenIdCounter.current()] = msg.sender;
            if (_percentBasisPoints > 0) {
                _setRoyalties(_tokenIdCounter.current());
            }

            _tokenIdCounter.increment();
        }

        payable(_treasuryWallet).transfer(msg.value);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        external
        onlyOwner
    {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setPrice(uint256 mintPrice) external onlyOwner {
        _price = mintPrice;
    }

    function price() public view returns (uint256) {
        return _price;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function _setRoyalties(uint256 _tokenId) private {
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = _percentBasisPoints;
        _royalties[0].account = _royaltiesWallet;
        _saveRoyalties(_tokenId, _royalties);
    }

    function setBasisPoints(uint96 value) external onlyOwner {
        require(value <= 10000, 'SavageSnowmen: Basis Points too high');
        _percentBasisPoints = value;
    }
}
