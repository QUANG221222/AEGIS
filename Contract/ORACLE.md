# Init oracle cedra_coin

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::init_price_feed --type-args 0x1::cedra_coin::CedraCoin --args u64:300000000000 --profile default2

# Init oracle any coin

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::init_price_feed --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:250000000000 --profile default2

edra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::init_price_feed --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::APT --args u64:800000000 --profile default2

# View price coin in usdt

cedra move view --function-id 0x48121ae8a5bb7e2875d1b7f41508f288c3f68514a3c4b4cb605024b3f8ccb36b::oracle::get_price_usdt --type-args 0x48121ae8a5bb7e2875d1b7f41508f288c3f68514a3c4b4cb605024b3f8ccb36b::coins::ETH --args address:0x48121ae8a5bb7e2875d1b7f41508f288c3f68514a3c4b4cb605024b3f8ccb36b --profile oracle

# Check exist price

cedra move view --function-id 0x48121ae8a5bb7e2875d1b7f41508f288c3f68514a3c4b4cb605024b3f8ccb36b::oracle::price_exists --type-args 0x48121ae8a5bb7e2875d1b7f41508f288c3f68514a3c4b4cb605024b3f8ccb36b::coins::ETH --args address:0x48121ae8a5bb7e2875d1b7f41508f288c3f68514a3c4b4cb605024b3f8ccb36b

# Update price coin in usdt

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::oracle::update_price --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:260000000000 --profile default2
