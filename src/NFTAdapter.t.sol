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
import { Vat } from "dss/vat.sol";
import { ERC721Mintable } from "./test/openzeppelin-solidity/token/ERC721/ERC721Mintable.sol";

contract TestUser {
    ERC721Mintable nft;
    NFTAdapter     ptr;

    constructor(ERC721Mintable nft_, NFTAdapter ptr_) public {
        nft = nft_;
        ptr = ptr_;
    }

    function approve(address to, uint256 tokenID) public {
        nft.approve(to, tokenID);
    }

    function join(address urn, uint256 tokenID) public {
        ptr.join(urn, tokenID);
    }

    function exit(uint256 tokenID, address pal) public {
        ptr.exit(pal, tokenID);
    }
}

contract NFTAdapterTest is DSTest {
    ERC721Mintable nft;
    GemLike        gem;
    NFTAdapter     ptr;
    TestUser       usr;
    Vat            vat;

    bytes32 ilk;

    bytes12 constant kin     = "fnord";
    uint256 tokenID = 42;

    function setUp() public {
        vat = new Vat();
        nft = new ERC721Mintable();
        gem = GemLike(address(nft));
        ptr = new NFTAdapter(address(vat), kin, address(gem));
        ilk = ptr.ilkName(kin, tokenID);
        usr = new TestUser(nft, ptr);

        vat.init(ilk);
        vat.rely(address(ptr));
        nft.mint(address(usr), tokenID);
        usr.approve(address(ptr), tokenID);
    }

    function test_balance() public {
        assertEq(nft.balanceOf(address(usr)), 1);
        assertEq(nft.balanceOf(address(ptr)), 0);
        assertEq(vat.gem(ilk, address(usr)), 0);

        usr.join(address(usr), tokenID);

        assertEq(nft.balanceOf(address(usr)), 0);
        assertEq(nft.balanceOf(address(ptr)), 1);
        assertEq(vat.gem(ilk, address(usr)), 1);

        usr.exit(tokenID, address(usr));

        assertEq(nft.balanceOf(address(usr)), 1);
        assertEq(nft.balanceOf(address(ptr)), 0);
        assertEq(vat.gem(ilk, address(usr)), 0);
    }

    function test_open_join() public {
        TestUser pal = new TestUser(nft, ptr);
        tokenID++;
        nft.mint(address(pal), tokenID);
        pal.approve(address(ptr), tokenID);

        pal.join(address(usr), tokenID);

        assertEq(vat.gem(ptr.ilkName(kin, tokenID), address(usr)), 1);
    }

    function test_exit_gift() public {
        TestUser pal = new TestUser(nft, ptr);
        assertEq(nft.balanceOf(address(pal)), 0);

        usr.join(address(usr), tokenID);
        usr.exit(tokenID, address(pal));

        assertEq(nft.balanceOf(address(pal)), 1);
    }

    function testFail_exit_steal() public {
        TestUser pal = new TestUser(nft, ptr);
        usr.join(address(usr), tokenID);

        pal.exit(tokenID, address(pal));
    }

    function testFail_tokenID_overflow() public {
        usr.join(address(usr), 2 ** 160);
    }
}
