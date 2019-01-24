# NFT Adapter

Reference implementation of an ERC-721 NFT adapter.

Becacuse each individual token must be its own _ilk_ (since risk parameters and
price feeds are per-_ilk_), we introduce the concept of _kin_, or family of
_ilk_s. An example of _kin_ is "cryptokitties".

An adapter must be deployed for each _kin_.

The adapter accepts NFT tokens (`obj`) with `join`, and adds
them to a user's CDP.

When the user wants to take the NFTs out of the system, they call `exit`.
