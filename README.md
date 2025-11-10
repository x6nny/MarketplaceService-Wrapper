# 🛒 Roblox Marketplace Module

A **typed Lua module** for Roblox Studio that provides a clean, reliable interface for interacting with the [`MarketplaceService`](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService).
This module simplifies **gamepass**, **developer product**, **subscription**, and **premium purchase** logic while maintaining full type safety and clean signal connections.

---

## 📦 Features

* ✅ Type-safe Marketplace wrapper (`--!strict`)
* 🧩 Built-in support for:

  * Game Passes
  * Developer Products
  * Premium Memberships
  * Bundles
  * Subscriptions
  * Bulk Purchases
* 🧠 Rich type definitions for `ProductInfo` and `Receipt`
* ⚙️ Safe, pcall-protected API requests
* 🧱 Signal wrappers for cleaner event connections

---

## 🧰 Installation

1. Place the module in **ReplicatedStorage** (recommended) or **ServerScriptService**.
2. Require it where needed:

   ```lua
   local Marketplace = require(game.ReplicatedStorage.Marketplace)
   ```

---

## 🧩 Type Definitions

### `Receipt`

Represents a transaction receipt from a player’s product purchase.

```lua
type Receipt = {
	PurchaseId: number,
	PlayerId: number,
	ProductId: number,
	PlaceIdWherePurchased: number,
	CurrencySpent: number,
	CurrencyType: Enum.CurrencyType,
	ProductPurchaseChannel: Enum.ProductPurchaseChannel
}
```

### `ProductInfo`

Describes product or asset metadata.

```lua
type ProductInfo = {
	Name: string,
	Description: string,
	PriceInRobux: number,
	ProductId: number,
	ProductType: string,
	Created: string,
	Updated: string,
	IsForSale: boolean,
	IsLimited: boolean,
	IsLimitedUnique: boolean,
	Sales: number,
	Creator: {
		CreatorType: "User" | "Group",
		Name: string,
		Id: number
	}
	-- Additional collectible and asset metadata
}
```

---

## ⚙️ API Reference

### 🎟️ Game Passes

#### `Marketplace.HasPass(UserId: number, PassId: number): boolean`

Checks if a player owns a given Game Pass.

```lua
if Marketplace.HasPass(player.UserId, 123456) then
	print("Player already owns this pass.")
end
```

#### `Marketplace.PromptPass(player: Player, PassId: number)`

Prompts a player to purchase a Game Pass (only if not already owned).

```lua
Marketplace.PromptPass(player, 123456)
```

---

### 💎 Developer Products

#### `Marketplace.PromptProduct(player: Player, ProductId: number)`

Prompts a player to purchase a developer product.

```lua
Marketplace.PromptProduct(player, 654321)
```

#### `Marketplace.PromptProductPurchaseFinished(callback)`

Connects a callback for when a developer product purchase finishes.

```lua
Marketplace.PromptProductPurchaseFinished(function(player, productId, wasPurchased)
	print(player.Name, "finished product purchase:", productId, "Purchased:", wasPurchased)
end)
```

---

### 💰 Premium Membership

#### `Marketplace.PromptPremiumPurchase(player: Player)`

Prompts a player to purchase Roblox Premium, if they don’t already have it.

```lua
Marketplace.PromptPremiumPurchase(player)
```

---

### 📦 Bulk Purchases

#### `Marketplace.BulkPurchase(player: Player, items: {{ Type: Enum.MarketplaceProductType, Id: number }}, options?: { any })`

Prompts a user to buy multiple products in a single transaction.

```lua
Marketplace.BulkPurchase(player, {
	{ Type = Enum.MarketplaceProductType.GamePass, Id = 12345 },
	{ Type = Enum.MarketplaceProductType.Product, Id = 67890 }
})
```

#### `Marketplace.PromptBulkPurchaseFinished(callback)`

Connects a callback for when a bulk purchase finishes.

```lua
Marketplace.PromptBulkPurchaseFinished(function(player, status, results)
	print("Bulk purchase completed for:", player.Name, "Status:", status)
end)
```

---

### 🧾 Subscriptions

#### `Marketplace.PromptSubscription(player: Player, SubscriptionId: string)`

Prompts the player to purchase a subscription.

```lua
Marketplace.PromptSubscription(player, "sub_1234")
```

#### `Marketplace.PromptSubscriptionCancel(player: Player, SubscriptionId: string)`

Prompts a user to cancel a subscription.

```lua
Marketplace.PromptSubscriptionCancel(player, "sub_1234")
```

#### `Marketplace.PromptSubscriptionPurchaseFinished(callback)`

Connects to subscription purchase completion events.

```lua
Marketplace.PromptSubscriptionPurchaseFinished(function(player, subId, didTry)
	print(player.Name, "tried purchasing subscription:", subId, "Success:", didTry)
end)
```

---

### 🧠 Product Info

#### `Marketplace.GetProductInfo(assetId: number, infoType: Enum.InfoType): ProductInfo?`

Fetches detailed product or asset data.

```lua
local info = Marketplace.GetProductInfo(123456, Enum.InfoType.Asset)
if info then
	print(info.Name .. " costs " .. info.PriceInRobux .. " Robux.")
end
```

---

## 🔌 Event Connection Shortcuts

| Function                                       | Description                                       |
| ---------------------------------------------- | ------------------------------------------------- |
| `PromptPurchaseFinished(callback)`             | Fires when an asset purchase prompt completes     |
| `PromptBundlePurchaseFinished(callback)`       | Fires when a bundle purchase completes            |
| `PromptGamePassPurchaseFinished(callback)`     | Fires when a game pass purchase completes         |
| `PromptBulkPurchaseFinished(callback)`         | Fires when a bulk purchase completes              |
| `PromptProductPurchaseFinished(callback)`      | Fires when a developer product purchase completes |
| `PromptSubscriptionPurchaseFinished(callback)` | Fires when a subscription purchase completes      |

Each method returns an `RBXScriptConnection`, which can be disconnected if needed.

---

## 🧩 Example Usage

```lua
local Marketplace = require(game.ReplicatedStorage.Marketplace)

-- Prompt a purchase
Marketplace.PromptProduct(player, 1234567)

-- Handle completion
Marketplace.PromptProductPurchaseFinished(function(player, productId, wasPurchased)
	if wasPurchased then
		print(player.Name .. " purchased product " .. productId)
	else
		print(player.Name .. " canceled the purchase.")
	end
end)
```

---

## 🧾 Handling Developer Product Receipts (Server Example)

To properly reward players for purchases, you should implement a **server-side receipt processor**.
This ensures items or currency are only granted **after Roblox confirms payment**.

> 💡 This code runs on the **server**, never on the client.

### Example: ProcessReceipt Handler

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Example product reward table
local ProductRewards = {
	[1234567] = function(player)
		player.leaderstats.Coins.Value += 100
		print(player.Name .. " was rewarded 100 Coins!")
	end,
	[7654321] = function(player)
		player.leaderstats.Gems.Value += 10
		print(player.Name .. " received 10 Gems!")
	end
}

-- Receipt processing function
local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Return NotProcessedYet if player isn't loaded yet
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local rewardFunc = ProductRewards[receiptInfo.ProductId]
	if rewardFunc then
		-- Grant the reward safely
		local success, err = pcall(function()
			rewardFunc(player)
		end)

		if success then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("Error processing receipt:", err)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	-- Unknown product
	warn("No reward found for product ID:", receiptInfo.ProductId)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Register the handler
MarketplaceService.ProcessReceipt = processReceipt
```

### Notes:

* Always verify player existence before granting rewards.
* Avoid granting items or currency on the client.
* Return:

  * `Enum.ProductPurchaseDecision.PurchaseGranted` — when the reward was successfully processed.
  * `Enum.ProductPurchaseDecision.NotProcessedYet` — when the player isn’t ready yet (Roblox will retry later).

---

## ⚖️ License

**MIT License © [YourNameHere]**

You’re free to use, modify, and distribute this module in both commercial and non-commercial Roblox projects.

---

## 🧠 Additional Notes

* All methods are **type-annotated** for Luau IntelliSense.
* `pcall` is used for network safety (to prevent runtime errors if Roblox services fail).
* Compatible with both **Server** and **Client** scripts (depending on purchase type).
* Server-only purchase validation is **highly recommended**.
