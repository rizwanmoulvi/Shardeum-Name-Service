// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import {Base64} from "./libraries/Base64.sol";
import {StringUtils} from "./libraries/StringUtils.sol";

contract Domains is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable public owner;
    mapping(uint256 => string) public names;
    mapping(string => string) public records;
    mapping(string => address) public domains;

    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);

    string public tld;
    string constant SVG_PART_ONE = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M 71.8 71.2 L 62.8 71.2 L 62.8 1.2 L 75.4 1.2 L 106.3 59.4 L 106.3 1.2 L 115.3 1.2 L 115.3 71.2 L 102.9 71.2 L 71.8 13.4 L 71.8 71.2 Z M 0 65.3 L 4.8 57.3 Q 8.4 60.3 12.9 62.2 A 23.348 23.348 0 0 0 18.27 63.71 A 32.118 32.118 0 0 0 23.4 64.1 A 27.981 27.981 0 0 0 27.947 63.754 Q 30.37 63.354 32.331 62.494 A 13.701 13.701 0 0 0 34.8 61.1 Q 38.848 58.209 38.995 53.366 A 12.116 12.116 0 0 0 39 53 A 11.94 11.94 0 0 0 38.663 50.107 A 9.816 9.816 0 0 0 37.8 47.85 A 8.097 8.097 0 0 0 36.6 46.194 Q 35.33 44.813 33.184 43.471 A 25.81 25.81 0 0 0 33.15 43.45 Q 30.034 41.508 24.265 39.28 A 118.584 118.584 0 0 0 23 38.8 Q 15.8 36 11.5 33.15 A 21.931 21.931 0 0 1 8.411 30.703 Q 6.694 29.053 5.638 27.188 A 13.303 13.303 0 0 1 5.35 26.65 Q 3.5 23 3.5 18 Q 3.5 13 6.25 8.95 Q 9 4.9 14.35 2.45 A 25.558 25.558 0 0 1 20.25 0.615 Q 23.493 0 27.3 0 Q 33.5 0 38.45 1.25 Q 43.4 2.5 48.1 4.8 L 44.6 12.9 A 31.496 31.496 0 0 0 40.474 10.881 A 41.686 41.686 0 0 0 36.65 9.55 Q 32.1 8.2 27.1 8.2 A 27.187 27.187 0 0 0 23.07 8.48 Q 20.938 8.8 19.2 9.487 A 12.616 12.616 0 0 0 16.7 10.8 A 9.902 9.902 0 0 0 14.537 12.765 A 7.359 7.359 0 0 0 12.9 17.5 A 10.464 10.464 0 0 0 13.192 20.022 A 8.562 8.562 0 0 0 14 22.1 Q 15.056 24.019 18.091 25.847 A 23.503 23.503 0 0 0 18.35 26 A 33.003 33.003 0 0 0 20.566 27.172 Q 22.835 28.275 26.046 29.523 A 130.016 130.016 0 0 0 28.1 30.3 A 81.228 81.228 0 0 1 33.078 32.329 Q 37.464 34.3 40.45 36.4 A 26.044 26.044 0 0 1 43.49 38.878 Q 45.713 41.006 46.9 43.35 A 17.579 17.579 0 0 1 48.641 49.213 A 22.155 22.155 0 0 1 48.8 51.9 A 21.71 21.71 0 0 1 48.133 57.401 A 17.105 17.105 0 0 1 45.55 63 Q 42.3 67.6 36.55 70 A 30.521 30.521 0 0 1 29.14 72.004 A 40.027 40.027 0 0 1 23.4 72.4 Q 16.1 72.4 10.1 70.45 A 38.206 38.206 0 0 1 4.733 68.268 A 28.433 28.433 0 0 1 0 65.3 Z M 127.3 65.3 L 132.1 57.3 Q 135.7 60.3 140.2 62.2 A 23.348 23.348 0 0 0 145.57 63.71 A 32.118 32.118 0 0 0 150.7 64.1 A 27.981 27.981 0 0 0 155.247 63.754 Q 157.67 63.354 159.631 62.494 A 13.701 13.701 0 0 0 162.1 61.1 Q 166.148 58.209 166.295 53.366 A 12.116 12.116 0 0 0 166.3 53 A 11.94 11.94 0 0 0 165.963 50.107 A 9.816 9.816 0 0 0 165.1 47.85 A 8.097 8.097 0 0 0 163.9 46.194 Q 162.63 44.813 160.484 43.471 A 25.81 25.81 0 0 0 160.45 43.45 Q 157.334 41.508 151.565 39.28 A 118.584 118.584 0 0 0 150.3 38.8 Q 143.1 36 138.8 33.15 A 21.931 21.931 0 0 1 135.711 30.703 Q 133.994 29.053 132.938 27.188 A 13.303 13.303 0 0 1 132.65 26.65 Q 130.8 23 130.8 18 Q 130.8 13 133.55 8.95 Q 136.3 4.9 141.65 2.45 A 25.558 25.558 0 0 1 147.55 0.615 Q 150.793 0 154.6 0 Q 160.8 0 165.75 1.25 Q 170.7 2.5 175.4 4.8 L 171.9 12.9 A 31.496 31.496 0 0 0 167.774 10.881 A 41.686 41.686 0 0 0 163.95 9.55 Q 159.4 8.2 154.4 8.2 A 27.187 27.187 0 0 0 150.37 8.48 Q 148.238 8.8 146.5 9.487 A 12.616 12.616 0 0 0 144 10.8 A 9.902 9.902 0 0 0 141.837 12.765 A 7.359 7.359 0 0 0 140.2 17.5 A 10.464 10.464 0 0 0 140.492 20.022 A 8.562 8.562 0 0 0 141.3 22.1 Q 142.356 24.019 145.391 25.847 A 23.503 23.503 0 0 0 145.65 26 A 33.003 33.003 0 0 0 147.866 27.172 Q 150.135 28.275 153.346 29.523 A 130.016 130.016 0 0 0 155.4 30.3 A 81.228 81.228 0 0 1 160.378 32.329 Q 164.764 34.3 167.75 36.4 A 26.044 26.044 0 0 1 170.79 38.878 Q 173.013 41.006 174.2 43.35 A 17.579 17.579 0 0 1 175.941 49.213 A 22.155 22.155 0 0 1 176.1 51.9 A 21.71 21.71 0 0 1 175.433 57.401 A 17.105 17.105 0 0 1 172.85 63 Q 169.6 67.6 163.85 70 A 30.521 30.521 0 0 1 156.44 72.004 A 40.027 40.027 0 0 1 150.7 72.4 Q 143.4 72.4 137.4 70.45 A 38.206 38.206 0 0 1 132.033 68.268 A 28.433 28.433 0 0 1 127.3 65.3 Z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string constant SVG_PART_TWO = '</text></svg>';

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    constructor(string memory _tld)
        payable
        ERC721("Shardeum Name Service", "CNS")
    {
        owner = payable(msg.sender);
        tld = _tld;
        console.log("%s name service deployed", _tld);
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }


    function register(string calldata name) public payable {
        if (domains[name] != address(0)) revert AlreadyRegistered();
        if (!valid(name)) revert InvalidName(name);
        require(domains[name] == address(0));

        string memory _name = string(abi.encodePacked(name, ".", tld));
        string memory finalSvg = string(
            abi.encodePacked(SVG_PART_ONE, _name, SVG_PART_TWO)
         );
        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);

        console.log(
            "Registering %s.%s on the contract with tokenID %d",
            name,
            tld,
            newRecordId
        );

        // Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                _name,
                '", "description": "A domain on the Shardeun Name Service", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '","length":"',
                strLen,
                '"}'
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log(
            "\n--------------------------------------------------------"
        );
        console.log("Final tokenURI", finalTokenUri);
        console.log(
            "--------------------------------------------------------\n"
        );

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        domains[name] = msg.sender;

        names[newRecordId] = name;
        _tokenIds.increment();
    }

    function getAllNames() public view returns (string[] memory) {
        console.log("Getting all names from contract");
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            allNames[i] = names[i];
            console.log("Name for token %d is %s", i, allNames[i]);
        }

        return allNames;
    }

    function valid(string calldata name) public pure returns (bool) {
        return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
    }

    function getAddress(string calldata name) public view returns (address) {
        // Check that the owner is the transaction sender
        return domains[name];
    }

    function setRecord(string calldata name, string calldata record) public {
        if (msg.sender != domains[name]) revert Unauthorized();
        records[name] = record;
    }

    function getRecord(string calldata name)
        public
        view
        returns (string memory)
    {
        return records[name];
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
    }
}
