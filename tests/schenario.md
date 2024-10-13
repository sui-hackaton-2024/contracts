This is a terminal scenario that allows to create a Sale with a SaleCap and from another wallet to participate into the LotterySale

(note this was before adding nb_winners in the args)

# this wallet will own the SaleCap
# export PACKAGE_ID=0xf9424b3cf95e969a21628cab6e8a07fe494be7d23938e789fd2ee165dc31534e
# sui client call --package $PACKAGE_ID --module LotterySale --function create_sale_cap --gas-budget 10000
# export SALECAP_ID=0xec7a4a16955816832dcd21fb37ddcfbb614e1a6c7141a0a7cce966ee6956291e
# sui client call --package $PACKAGE_ID --module LotterySale --function create_sale --args $SALECAP_ID 100 --gas-budget 10000
# export SALE_ID=0x130fbfe0a3913fcc4fa2d918af66252ec27da44cbfac020a3fac9f18aff684d3

# this next part can be done from another wallet
# export COIN_ID=<some SUI coin in your wallet or objects?>
# ex: export COIN_ID=0xedb8008f1cce5756da3fea2cdcff7e01c368729219f5c3ea057fad3efd0c9150
# sui client call --function participate --module LotterySale --package $PACKAGE_ID --args $SALE_ID $COIN_ID --gas-budget 100000000

# ex after participate: 0x130fbfe0a3913fcc4fa2d918af66252ec27da44cbfac020a3fac9f18aff684d3
# you can see 2 wallets participating in the auction here: https://suiscan.xyz/testnet/object/0x130fbfe0a3913fcc4fa2d918af66252ec27da44cbfac020a3fac9f18aff684d3/txs

