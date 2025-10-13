# Create Pool

cedra move run --function-id 6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175::pool_manager::create_pool --type-args 0x1::cedra_coin::CedraCoin --profile pool

cedra move run --function-id 0x11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62::pool_manager::create_pool --type-args 0x11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62::coins::ETH --profile wang4

# Check exit

cedra move view --function-id 6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175::pool::pool_exists --type-args 0x1::cedra_coin::CedraCoin --args address:6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175 --profile pool

cedra move view --function-id 11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62::pool::pool_exists --type-args 0x11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa
62::coins::ETH --args address:11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62 -
-profile wang4

# Get Total Supply

cedra move view --function-id 11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62::pool::get_total_supply --type-args 0x1::cedra_coin::CedraCoin --args address:11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62 --profile wang4

# Get pool stats

cedra move view --function-id 6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175::pool::get_pool_stats --type-args 0x1::cedra_coin::CedraCoin --args address:6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175 --profile pool

cedra move view --function-id 11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62::pool::get_pool_stats --type-args 0x11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62::coins::ETH --args address:11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62 --profile wang4
