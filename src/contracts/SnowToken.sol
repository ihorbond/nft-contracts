// SPDX-License-Identifier: MIT
// SnowToken v0.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SnowToken is
    ERC20,
    ERC20Burnable,
    ERC20Permit,
    ERC20Votes,
    Pausable,
    Ownable
{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public _cap;

    uint256[] public _tokenomics;

    address[] public _mintWallets;

    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
        ERC20Permit(name)
    {
        _cap = 250000000 ether;
        _tokenomics = [
            100000000 ether, // mint to lock wallet
            50000000 ether, // mint to treasury wallet
            20000000 ether, // mint for initial liquidity
            30000000 ether, // mint for LP farm
            50000000 ether // mint for PolyientX vault
        ];
        _mintWallets = [
            address(0x1), // lock wallet
            address(0x2), // treasury wallet
            address(0x3), // liquidity manager wallet
            address(0x4), // LP farm manager wallet
            address(0x5) // PolyientX vault manager wallet
        ];
    }

    function updateTokenomics(
        address[] memory mintWallets_,
        uint256[] memory tokenmics_
    ) public onlyOwner {
        delete _mintWallets;
        delete _tokenomics;
        require(mintWallets_.length == tokenmics_.length, "Mismatch data size");
        uint256 totalCap_ = 0;
        for (uint256 i = 0; i < mintWallets_.length; i++) {
            if (mintWallets_[i] == address(0x0)) continue;
            _mintWallets.push(mintWallets_[i]);
            _tokenomics.push(tokenmics_[i]);
            totalCap_ = totalCap_.add(tokenmics_[i]);
        }
        require(totalCap_ == _cap, "Mismatch total supply");
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mintAll() public onlyOwner {
        for (uint256 i = 0; i < _tokenomics.length; i++) {
            _mint(_mintWallets[i], _tokenomics[i]);
        }
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(
            totalSupply().add(amount) <= _cap,
            "$sno::mint: cannot exceed max supply"
        );
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
