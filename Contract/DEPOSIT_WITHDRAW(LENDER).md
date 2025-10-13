# Deposit

cedra move run --function-id 6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175::lending::deposit --type-args 0x1::cedra_coin::CedraCoin --args address:6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175 u64:20000000 --profile lender1

# Check coin of user deposited

cedra move view --function-id 0x6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175::pool::get_user_deposit --type-args 0x1::cedra_coin::CedraCoin --args address:0x6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175 address:0xdbc4fc35f8024a7cb7cf5c1ebee691be95b621fb4a6d412b80361eb5e710621c

cedra move view --function-id 0x11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62::pool::get_user_deposit --type-args 0x1::cedra_coin::CedraCoin --args address:0x11f3de6a525fcf20818d10be7ed829dbc806054f8d210b2d6a2bd7177c76aa62 address:0x
c5d820ccb43309f2cbe0a70b184ce0e12204451c17717cf427bd7e0060e483af

# Check coin of user can withdraw

cedra move view --function-id 0x6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175::withdraw::get_withdrawable_amount --type-args 0x1::cedra_coin::CedraCoin --args address:0x6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175 address:0xdbc4fc35f8024a7cb7cf5c1ebee691be95b621fb4a6d412b80361eb5e710621c

# Withdraw and check

cedra move run --function-id 6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175::withdraw::withdraw_from_pool --type-args 0x1::cedra_coin::CedraCoin --args address:6a3dec044b92d5a5367513a4bcf5287000eaaafb906c81339fde4298f3ff9175 u64:2000000000 --profile lender1
