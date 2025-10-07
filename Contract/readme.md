<!-- get balance in cedra coin  -->

cedra account balance --profile default2

<!-- init oracle cedra_coin -->

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::init_price_feed --type-args 0x1::cedra_coin::CedraCoin --args u64:300000000000 --profile default2

<!-- init oracle any coin  -->

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::init_price_feed --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:250000000000 --profile default2

edra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::init_price_feed --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::APT --args u64:800000000 --profile default2

<!-- view price coin in usdt -->

cedra move view --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::get_price_usdt --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default2

<!-- update price coin in usdt -->

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::update_price --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:260000000000 --profile default2

<!-- init collateral config -->

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::init_collateral_config --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:7500 u64:8000 u64:500 u64:100000000 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default

<!-- init collateral account -->

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::init_collateral_account --profile default2

<!-- get collateral amount -->

cedra move view --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::get_collateral_amount --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default2

<!-- calculate health factor single -->

cedra move view --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::calculate_health_factor_single --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:1000000 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default2

<!-- check is luiquitable -->

cedra move view --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::is_liquidatable --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default2

<!-- deposit cedra coin to collateral -->

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::deposit_collateral --type-args 0x1::cedra_coin::CedraCoin --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 u64:10000000 --profile default2

<!-- withdraw cedra coin in collateral -->

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::withdraw_collateral --type-args 0x1::cedra_coin::CedraCoin --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 u64:5000000 --profile default2
