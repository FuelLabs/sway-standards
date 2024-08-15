use fuels::{
    accounts::ViewOnlyAccount,
    prelude::{
        abigen, launch_custom_provider_and_get_wallets, AssetConfig, Contract, ContractId,
        LoadConfiguration, TxPolicies, WalletUnlocked, WalletsConfig,
    },
    types::{Address, AssetId, Bits256, Bytes32, Identity},
};

abigen!(Contract(
    name = "MultiAsset",
    abi = "./examples/src3_mint_burn/multi_asset/out/release/multi_src3_asset-abi.json"
));

const MULTI_ASSET_CONTRACT_BINARY_PATH: &str = "./out/release/multi_asset.bin";

pub(crate) async fn setup() -> (WalletUnlocked, ContractId, MultiAsset<WalletUnlocked>) {
    let number_of_coins = 1;
    let coin_amount = 100_000_000;
    let number_of_wallets = 1;

    let base_asset = AssetConfig {
        id: AssetId::zeroed(),
        num_coins: number_of_coins,
        coin_amount,
    };
    let assets = vec![base_asset];

    let wallet_config = WalletsConfig::new_multiple_assets(number_of_wallets, assets);
    let mut wallets = launch_custom_provider_and_get_wallets(wallet_config, None, None)
        .await
        .unwrap();

    let wallet1 = wallets.pop().unwrap();

    let id = Contract::load_from(
        MULTI_ASSET_CONTRACT_BINARY_PATH,
        LoadConfiguration::default(),
    )
    .unwrap()
    .deploy(&wallet1, TxPolicies::default())
    .await
    .unwrap();

    let instance_1 = MultiAsset::new(id.clone(), wallet1.clone());

    (wallet1, id.into(), instance_1)
}
