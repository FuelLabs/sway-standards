use fuels::{
    prelude::{
        abigen, launch_custom_provider_and_get_wallets, AssetConfig, Contract, ContractId,
        LoadConfiguration, TxPolicies, WalletUnlocked, WalletsConfig,
    }, programs::calls::CallParameters, types::{transaction_builders::VariableOutputPolicy, AssetId, Bits256},
    tx::ContractIdExt,
};

abigen!(Contract(
    name = "SingleAsset",
    abi = "./single_asset/out/release/single_src20_asset-abi.json"
));

const SINGLE_ASSET_CONTRACT_BINARY_PATH: &str =
    "./single_asset/out/release/single_src20_asset.bin";

pub(crate) async fn setup() -> (WalletUnlocked, ContractId, SingleAsset<WalletUnlocked>) {
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
        SINGLE_ASSET_CONTRACT_BINARY_PATH,
        LoadConfiguration::default(),
    )
    .unwrap()
    .deploy(&wallet1, TxPolicies::default())
    .await
    .unwrap();

    let instance_1 = SingleAsset::new(id.clone(), wallet1.clone());

    (wallet1, id.into(), instance_1)
}