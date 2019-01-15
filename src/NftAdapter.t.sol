pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./NftAdapter.sol";

contract NftAdapterTest is DSTest {
    NftAdapter adapter;

    function setUp() public {
        adapter = new NftAdapter();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
