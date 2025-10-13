# Get balance in cedra coin

cedra account balance --profile default2

# Init collateral config

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::init_collateral_config --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:7500 u64:8000 u64:500 u64:100000000 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default

# Init collateral account

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::init_collateral_account --profile default2

# Get collateral amount

cedra move view --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::get_collateral_amount --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default2

# Calculate health factor single

cedra move view --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::calculate_health_factor_single --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args u64:1000000 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default2

# Check is luiquitable

cedra move view --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::is_liquidatable --type-args 0xd87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::coins::ETH --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 --profile default2

# Deposit cedra coin to collateral

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::deposit_collateral --type-args 0x1::cedra_coin::CedraCoin --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 u64:10000000 --profile default2

# Withdraw cedra coin in collateral

cedra move run --function-id d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7::collateral::withdraw_collateral --type-args 0x1::cedra_coin::CedraCoin --args address:d87d24265d5ffda4fc167d11a117a0130881c1bcd63a014c163110a5512ec1e7 u64:5000000 --profile default2
