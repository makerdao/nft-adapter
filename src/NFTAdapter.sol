/// NFTAdapter.sol -- Reference EIP-721-compliant non-fungible token adapter

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

    int256 constant ONE = 10 ** 45;

    constructor(address vat_, bytes12 kin_, address gem_) public {
        vat = VatLike(vat_);
        kin = kin_;
        gem = GemLike(gem_);
    }

    function join(bytes32 urn, uint160 obj) external note {
        require(bytes20(urn) == bytes20(msg.sender));

        gem.transferFrom(msg.sender, address(this), obj);
        vat.slip(ilkName(kin, obj), urn,  ONE);
    }

    function exit(bytes32 urn, uint160 obj) external note {
        require(bytes20(urn) == bytes20(msg.sender));

        gem.transferFrom(address(this), msg.sender, obj);
        vat.slip(ilkName(kin, obj), urn, -ONE);
    }

    function ilkName(bytes12 kin, uint160 obj) internal pure returns (bytes32 ilk) {
        ilk = bytes32(uint256(bytes32(kin)) + uint256(obj));
    }
}

contract VatLike {
    function slip(bytes32,bytes32,int256) public;
}

contract GemLike {
    function transferFrom(address,address,uint256) external payable;
    function safeTransferFrom(address,address,uint256) external payable;
}
