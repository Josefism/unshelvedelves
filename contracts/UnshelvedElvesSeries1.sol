//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
contract UnshelvedElvesSeries1 is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;

    uint public constant MAX_SUPPLY = 20000;
    uint public constant PRICE = 10 ether;
    uint public constant MAX_PER_MINT = 5;
    uint public PRESALE_STATUS;
    string public baseTokenURI;

    constructor(string memory baseURI) ERC721("Unshelved Elves (Series 1)", "UE1") {
        setBaseURI(baseURI);
        _tokenIds.increment();
        PRESALE_STATUS = 1;
    }
	
    function name() override public pure returns (string memory) {
        return "Unshelved Elves (Series 1)";
    }

    function symbol() override public pure returns (string memory) {
        return "UE1";
    }

    function reserveNFTs(uint _count) public onlyOwner {
        uint totalMinted = _tokenIds.current();
        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFTs");
        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIds.current();
        uint bulkPrice = PRICE;
        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs remain!");
        require(_count > 0 && _count <= MAX_PER_MINT, "Cannot mint more than 5 NFTs at once.");
        if (PRESALE_STATUS > 0 && _count == 2) {
            bulkPrice = 8 ether;
        } else if (PRESALE_STATUS > 0 && _count == 3) {
            bulkPrice = 7 ether;
        } else if (PRESALE_STATUS > 0 && _count == 4) {
            bulkPrice = 6 ether;
        } else if (PRESALE_STATUS > 0 && _count == 5) {
            bulkPrice = 5 ether;
        }
        require(msg.value >= (bulkPrice.mul(_count) + 0.01 ether), "Not enough MATIC to purchase NFTs.");
        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);
        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function closePresale() public onlyOwner {
        PRESALE_STATUS = 0;
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No matic left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}