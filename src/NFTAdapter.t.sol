pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./NFTAdapter.sol";

contract NFTAdapterTest is DSTest {
    NFTAdapter adapter;

    function setUp() public {
        adapter = new NFTAdapter();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
