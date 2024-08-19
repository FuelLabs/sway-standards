use fuels::{
    prelude::{
        abigen, launch_custom_provider_and_get_wallets, AssetConfig, Contract, ContractId,
        LoadConfiguration, TxPolicies, WalletUnlocked, WalletsConfig,
    }, programs::calls::CallParameters, types::{transaction_builders::VariableOutputPolicy, AssetId, Bits256}
};

abigen!(Contract(
    name = "SingleAsset",
    abi = "./examples/src3_mint_burn/single_asset/out/release/single_src3_asset-abi.json"
));

const SINGLE_ASSET_CONTRACT_BINARY_PATH: &str =
    "./examples/src3_mint_burn/single_asset/out/release/single_src3_asset.bin";

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

#[tokio::test]
async fn test_mint_single_asset() {
    let (wallet1, _id, instance) = setup().await;

    let _mint_tx = instance
        .methods()
        .mint(wallet1.address().into(), Bits256::zeroed(), 100)
        .with_variable_output_policy(VariableOutputPolicy::Exactly(1))
        .call()
        .await
        .unwrap();
}

#[tokio::test]
async fn test_burn_single_asset() {
    let (wallet1, id, instance) = setup().await;

    let _mint_tx = instance
        .methods()
        .mint(wallet1.address().into(), Bits256::zeroed(), 100)
        .with_variable_output_policy(VariableOutputPolicy::Exactly(1))
        .call()
        .await
        .unwrap();

    let _burn_tx = instance
        .methods()
        .burn(Bits256::zeroed(), 100)
        .call_params(
            CallParameters::default()
                .with_asset_id(id.default_asset())
                .with_amount(100),
        )
        .unwrap()
        .call()
        .await
        .unwrap();
}
