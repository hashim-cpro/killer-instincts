extends Control

func setCoinAmount(coins):
	$CoinContainer/CoinAmount.text = str(coins)

func getCoinAmount():
	return int($CoinContainer/CoinAmount.text)
