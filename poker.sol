// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity >=0.8.13 <0.9.0;

import "fhevm/abstracts/EIP712WithModifier.sol";
import "fhevm/lib/TFHE.sol";
import "hardhat/console.sol";

contract Poker is EIP712WithModifier {

    constructor() EIP712WithModifier("Authorization token", "1") {
        owner = msg.sender;
    }

    address public owner;
    //mapping(uint8 => euint8) deck;
    euint8 count;
    uint8 countPlain;


    euint8[] public deck;
    mapping(address => euint8[]) players;
    address[] playersArray;

    // function test() public {
    //     euint8 card = TFHE.randEuint8();
    //     if (countPlain == 0) {
    //         deck[count] = card;
    //         count = TFHE.add(count, TFHE.asEuint8(1));
    //         countPlain += 1;
    //     } 
    //     euint8 total;
    //     for (uint8 i = 0; i < countPlain; i++) {
    //         ebool duplicate = TFHE.eq(deck[i], card);
    //         total = TFHE.add(total, TFHE.cmux(duplicate, TFHE.asEuint8(1), TFHE.asEuint8(0)));
    //     }
    //     count = TFHE.add(count, TFHE.asEuint8(1)); // add one
    // }


    function checkDuplication(euint8 _card) internal view returns (euint8) {
        euint8 total;
        for (uint8 i = 0; i < deck.length; i++) {
            ebool duplicate = TFHE.eq(deck[i], _card);
            total = TFHE.add(total, TFHE.cmux(duplicate, TFHE.asEuint8(1), TFHE.asEuint8(0)));
        }
        return total;
    }

    function dealCard() public {
        euint8 card = TFHE.randEuint8();
        if (deck.length == 0) {
            deck.push(card);
        } else if (TFHE.decrypt(checkDuplication(card)) == 0) {
            deck.push(card);
        }
    }

    function setDeal(uint8 n) public { //this count is 2n + 5 
        for (uint8 i = 0; i < n; i++) {
            dealCard();
        }
    } 

    function getArray() public view returns (euint8[] memory) {
        return deck;
    }

    function getLength() public view returns (uint) {
        return deck.length;
    }

    function joinGame() public {
        players[msg.sender].push(deck[deck.length - 2]);
        players[msg.sender].push(deck[deck.length - 1]);
    }

    function checkFirstCard(bytes32 publicKey, bytes calldata signature) public view onlySignedPublicKey(publicKey, signature) returns (bytes memory) {
        return  TFHE.reencrypt(players[msg.sender][0], publicKey, 0);
    }
    function checkSecondCard(bytes32 publicKey, bytes calldata signature) public view onlySignedPublicKey(publicKey, signature) returns (bytes memory) {
        return  TFHE.reencrypt(players[msg.sender][1], publicKey, 0);
    }



}