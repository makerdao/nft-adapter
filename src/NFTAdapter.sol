/*

________________███▄____█___█████▒▄▄▄█████▓___________________
________________██_▀█___█_▓██___▒_▓__██▒_▓▒___________________
_______________▓██__▀█_██▒▒████_░_▒_▓██░_▒░___________________
_______________▓██▒__▐▌██▒░▓█▒__░_░_▓██▓_░____________________
_______________▒██░___▓██░░▒█░______▒██▒_░____________________
_______________░_▒░___▒_▒__▒_░______▒_░░______________________
_______________░_░░___░_▒░_░__________░_______________________
__________________░___░_░__░_░______░_________________________
________________________░_____________________________________
______________________________________________________________
_▄▄▄______▓█████▄__▄▄▄_______██▓███__▄▄▄█████▓▓█████__██▀███__
▒████▄____▒██▀_██▌▒████▄____▓██░__██▒▓__██▒_▓▒▓█___▀_▓██_▒_██▒
▒██__▀█▄__░██___█▌▒██__▀█▄__▓██░_██▓▒▒_▓██░_▒░▒███___▓██_░▄█_▒
░██▄▄▄▄██_░▓█▄___▌░██▄▄▄▄██_▒██▄█▓▒_▒░_▓██▓_░_▒▓█__▄_▒██▀▀█▄__
_▓█___▓██▒░▒████▓__▓█___▓██▒▒██▒_░__░__▒██▒_░_░▒████▒░██▓_▒██▒
_▒▒___▓▒█░_▒▒▓__▒__▒▒___▓▒█░▒▓▒░_░__░__▒_░░___░░_▒░_░░_▒▓_░▒▓░
__▒___▒▒_░_░_▒__▒___▒___▒▒_░░▒_░_________░_____░_░__░__░▒_░_▒░
__░___▒____░_░__░___░___▒___░░_________░_________░_____░░___░_
______░__░___░__________░__░_____________________░__░___░_____
___________░__________________________________________________

        EIP-721-compliant non-fungible token adapter

*/

// Copyright (C) 2019 Lorenzo Manacorda <lorenzo@mailbox.org>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.5.0;

import "ds-note/note.sol";

contract NFTAdapter is DSNote {
    VatLike public vat;
    bytes12 public kin;
    GemLike public gem;

    constructor(address vat_, bytes12 kin_, address gem_) public {
        vat = VatLike(vat_);
        kin = kin_;
        gem = GemLike(gem_);
    }

    function join(address urn, uint256 obj) external note {
        require(uint256(uint160(obj)) == obj, "obj-overflow");

        gem.transferFrom(msg.sender, address(this), obj);
        vat.slip(ilkName(kin, obj), urn,  1);
    }

    function exit(address usr, uint256 obj) external note {
        require(uint256(uint160(obj)) == obj, "obj-overflow");

        gem.transferFrom(address(this), usr, obj);
        vat.slip(ilkName(kin, obj), msg.sender, -1);
    }

    // the ilk name is the concatenation of 12 bytes of kin + 20 bytes of obj
    function ilkName(bytes12 kin_, uint256 obj_) public pure returns (bytes32 ilk) {
        ilk = bytes32(uint256(bytes32(kin_)) + uint256(uint160(obj_)));
    }
}

contract VatLike {
    function slip(bytes32,address,int256) public;
}

contract GemLike {
    function transferFrom(address,address,uint256) external payable;
    function safeTransferFrom(address,address,uint256) external payable;
}
