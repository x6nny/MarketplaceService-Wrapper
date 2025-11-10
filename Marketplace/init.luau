--!strict
local MarketplaceService = game:GetService('MarketplaceService')
local Players = game:GetService('Players')

--> Types
export type Receipt = {
	PurchaseId : number,
	PlayerId : number,
	ProductId : number,
	PlaceIdWherePurchased : number,
	CurrencySpent : number,
	CurrencyType : Enum.CurrencyType,
	ProductPurchaseChannel : Enum.ProductPurchaseChannel
}

export type ProductInfo = {
	--> Basic information
	Name : string,
	Description : string,
	PriceInRobux : number,
	ProductId : number,
	ProductType : string,
	Created : string,
	Updated : string,
	ContentRatingTypeId : number,
	MinimumMembershipLevel : number,
	IsPublicDomain : boolean,
	TargetId : number,
	
	--> Creator Information
	Creator : {
		CreatorType : 'User' | 'Group',
		CreatorTargetId : number,
		HasVerifiedBadge : boolean,
		Name : string,
		Id : number
	},
	
	--> Asset Information
	AssetId : number,
	AssetTypeId : number,
	IconImageAssetId : number,
	IsForSale : boolean,
	IsLimited : boolean,
	IsLimitedUnique : boolean,
	IsNew : boolean,
	Remaining : number,
	Sales : number,
	
	--> Collectibles Information
	CollectibleItemId : string,
	CollectibleProductId : string,
	CollectiblesItemDetails : {
		CollectibleLowestAvailableResaleItemInstanceId : number,
		CollectibleLowestAvailableResaleProductId : number,
		CollectibleLowestResalePrice : number,
		IsForSale : boolean,
		IsLimited : boolean,
		TotalQuantity : number
	},
	
	--> Sale Location Settings
	CanBeSoldInThisGame : boolean,
	SalesLocation : {
		SaleLocationType : number,
		UniverseIds : {number}
	},
}

--> Main
local Marketplace = {}

--> Methods

--[=[

	Check if a player owns a gamepass
	@param UserId number
	@param PassId number
	@return boolean

]=]
function Marketplace.HasPass(UserId : number, PassId : number) : boolean
	return MarketplaceService:UserOwnsGamePassAsync(UserId, PassId)
end


--[=[

	Prompt a user to purchase a gamepass
	@public
	@param player Player
	@param PassId number

]=]
function Marketplace.PromptPass(player : Player, PassId : number)
	if Marketplace.HasPass(player.UserId, PassId) == true then return end
	MarketplaceService:PromptGamePassPurchase(player, PassId)
end

--[=[

	Prompt a user to purchase a developer product
	@public
	@param player Player
	@param ProductId number

]=]
function Marketplace.PromptProduct(player : Player, ProductId : number)
	MarketplaceService:PromptProductPurchase(player, ProductId)
end

--[=[

	Prompt a user to purchase Premium membership
	@public
	@param player Player

]=]
function Marketplace.PromptPremiumPurchase(player : Player)
	if player.MembershipType == Enum.MembershipType.Premium then return end
	MarketplaceService:PromptPremiumPurchase(player)
end

--[=[

	Prompt a user to complete a bulk purchase
	@public
	@param player Player
	@param items table
	@param options table

]=]
function Marketplace.BulkPurchase(player : Player, items : {{Type : Enum.MarketplaceProductType, Id : number}}, options : {any}?)
	MarketplaceService:PromptBulkPurchase(player, items, options or {})
end

--[=[

	Prompt a user to purchase a subscription
	@public
	@param player Player
	@param SubscriptionId string

]=]
function Marketplace.PromptSubscription(player : Player, SubscriptionId : string)
	MarketplaceService:PromptSubscriptionPurchase(player, SubscriptionId)
end

--[=[

	Prompt a user to cancel a subscription
	@public
	@param player Player
	@param SubscriptionId string

]=]
function Marketplace.PromptSubscriptionCancel(player : Player, SubscriptionId : string)
	MarketplaceService:PromptCancelSubscription(player, SubscriptionId)
end

--[=[

	Connects a function to PromptBulkPurchaseFinished
	@public
	@param callBack function
	@returns RBXScriptConnection

]=]
function Marketplace.PromptBulkPurchaseFinished(callBack : (player : Player, status : Enum.MarketplaceBulkPurchasePromptStatus, results : { [string]: any }) -> ())
	return MarketplaceService.PromptBulkPurchaseFinished:Connect(callBack)
end

--[=[

	Connects a function to PromptPurchaseFinished
	@public
	@param callBack function
	@returns RBXScriptConnection

]=]
function Marketplace.PromptPurchaseFinished(callBack : (player : Player, AssetId : number, WasPurchased : boolean) -> ())
	return MarketplaceService.PromptPurchaseFinished:Connect(callBack)
end

--[=[

	Connects a function to PromptBundlePurchaseFinished
	@public
	@param callBack function
	@returns RBXScriptConnection

]=]
function Marketplace.PromptBundlePurchaseFinished(callBack : (player : Player, BundleId : number, WasPurchased : boolean) -> ())
	return MarketplaceService.PromptBundlePurchaseFinished:Connect(callBack)
end

--[=[

	Connects a function to PromptProductPurchaseFinished
	@public
	@param callBack function
	@returns RBXScriptConnection

]=]
function Marketplace.PromptProductPurchaseFinished(callBack : (player : Player, ProductId : number, WasPurchased : boolean) -> ())
	return MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId : number, ...)
		local player = Players:GetPlayerByUserId(userId)
		if player then
			callBack(player, ...)
		end
	end)
end

--[=[

	Connects a function to PromptGamePassPurchaseFinished
	@public
	@param callBack function
	@returns RBXScriptConnection

]=]
function Marketplace.PromptGamePassPurchaseFinished(callBack : (player : Player, PassId : number, WasPurchased : boolean) -> ())
	return MarketplaceService.PromptGamePassPurchaseFinished:Connect(callBack)
	
end

--[=[

	Connects a function to PromptSubscriptionPurchaseFinished
	@public
	@param callBack function
	@returns RBXScriptConnection

]=]
function Marketplace.PromptSubscriptionPurchaseFinished(callBack : (player : Player, SubscriptionId : string, didTryPurchasing : boolean) -> ())
	return MarketplaceService.PromptSubscriptionPurchaseFinished:Connect(callBack)
end

--[=[

	Gets the info of an asset / product
	@public
	@param assetId number
	@param infoType Enum.InfoType
	@returns ProductInfo | nil

]=]
function Marketplace.GetProductInfo(assetId : number, infoType : Enum.InfoType) : ProductInfo?
	local succ, info = pcall(function()
		return MarketplaceService:GetProductInfo(assetId, infoType)
	end)
	
	if succ and typeof(info) == 'table' then
		return info
	end
	
	return nil
end

--> return
return Marketplace