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

import "ds-test/test.sol";

import { GemLike, NFTAdapter } from "./NFTAdapter.sol";
import { Vat } from "dss/tune.sol";
import { ERC721Mintable } from "./test/openzeppelin-solidity/token/ERC721/ERC721Mintable.sol";

contract TestUser {
    ERC721Mintable nft;
    NFTAdapter     ptr;

    constructor(ERC721Mintable nft_, NFTAdapter ptr_) public {
        nft = nft_;
        ptr = ptr_;
    }

    function approve(address to, uint256 tokenId) public {
        nft.approve(to, tokenId);
    }

    function join(uint256 tokenId) public {
        ptr.join(bytes32(bytes20(address(this))), tokenId);
    }

    function exit(uint256 tokenId) public {
        ptr.exit(bytes32(bytes20(address(this))), tokenId);
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4) {
      return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}

contract NFTAdapterTest is DSTest, NFTAdapter {
    ERC721Mintable nft;
    GemLike        gem;
    NFTAdapter     ptr;
    TestUser       usr;
    Vat            vat;

    bytes32 ilk;
    bytes32 urn;

    bytes12 constant kin     = "fnord";
    uint256 constant ONE     = 10 ** 45;
    uint256 constant tokenId = 42;

    function setUp() public {
        vat = new Vat();
        ilk = ilkName(kin, tokenId);
        nft = new ERC721Mintable();
        gem = GemLike(address(nft));
        ptr = new NFTAdapter(address(vat), kin, address(gem));
        usr = new TestUser(nft, ptr);
        urn = bytes32(bytes20(address(usr)));

        vat.init(ilk);
        vat.rely(address(ptr));
        nft.mint(address(usr), tokenId);
        usr.approve(address(ptr), tokenId);
    }

    function test_balance() public {
        assertEq(nft.balanceOf(address(usr)), 1);
        assertEq(nft.balanceOf(address(ptr)), 0);
        assertEq(vat.gem(ilk, urn), 0);

        usr.join(tokenId);

        assertEq(nft.balanceOf(address(usr)), 0);
        assertEq(nft.balanceOf(address(ptr)), 1);
        assertEq(vat.gem(ilk, urn), ONE);

        usr.exit(tokenId);

        assertEq(nft.balanceOf(address(usr)), 1);
        assertEq(nft.balanceOf(address(ptr)), 0);
        assertEq(vat.gem(ilk, urn), 0);
    }

    function ilkName(bytes12 kin, uint256 obj) internal pure returns (bytes32 ilk) {
        ilk = bytes32(uint256(bytes32(kin)) + uint256(uint160(obj)));
    }
}
