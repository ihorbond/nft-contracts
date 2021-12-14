// SPDX-License-Identifier: MIT
// SavageSnowmen v0.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SavageSnowmen is
    ERC721,
    IERC2981,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Pausable,
    Ownable
{
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256 public PRICE = 2500000000000000000; //2.5 avax
    uint256 public cap;

    string private _tokenBaseURI;
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    address payable private _proceedsPaymentsAddress;
    address payable private _royaltiesPaymentsAddress;

    constructor(
        string memory name,
        string memory symbol,
        string memory tokenBaseURI,
        uint256 cap_,
        address proceedsPaymentsAddress,
        address royaltiesPaymentAddress
    ) ERC721(name, symbol)
    {
        cap = cap_;
        _tokenBaseURI = tokenBaseURI;
        _proceedsPaymentsAddress = payable(proceedsPaymentsAddress);
        _royaltiesPaymentsAddress = payable(royaltiesPaymentAddress);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /// @inheritdoc	ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, IERC165, ERC721Enumerable)
        returns (bool)
    {
        return interfaceId == _INTERFACE_ID_ERC2981 || super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _tokenBaseURI = uri;
    }

    // function setRoyaltiesWallet(address payable wallet) external onlyOwner {
    //     _royaltiesWallet = wallet;
    // }

    function _baseURI() internal view virtual override returns (string memory) {
        return _tokenBaseURI;
    }

    function mint(uint256 amount) external payable whenNotPaused {
        require(
            msg.value >= PRICE.mul(amount),
            "SavageSnowmen: invalid amount sent"
        );
        require(
            _tokenIdCounter.current().add(amount) <= cap,
            "SavageSnowmen: supply too low to mint amount"
        );
        require(amount > 0, "Number of requested tokens has to be greater than 0");

        for (uint256 x = 0; x < amount; x++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();

            _safeMint(owner(), tokenId);

            _transfer(owner(), msg.sender, tokenId);
        }
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "No balance");

        _proceedsPaymentsAddress.transfer(address(this).balance);
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
        PRICE = mintPrice;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(ERC721URIStorage.tokenURI(tokenId), ".json"));
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        uint bp = 550; // 5.5% royalties in basis points
        return (_proceedsPaymentsAddress, salePrice.mul(bp).div(10000));
    }
}
