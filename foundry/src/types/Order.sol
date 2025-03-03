// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

library Order {
    enum OrderType {
        // Market swap
        MarketSwap,
        // Limit order swap
        LimitSwap,
        // Increase position
        MarketIncrease,
        // TODO: wat dis?
        LimitIncrease,
        // Decrease position
        MarketDecrease,
        // Take profit
        LimitDecrease,
        // Stop loss
        StopLossDecrease,
        Liquidation,
        // TODO: wat dis?
        StopIncrease
    }

    enum SecondaryOrderType {
        None,
        Adl
    }

    enum DecreasePositionSwapType {
        NoSwap,
        SwapPnlTokenToCollateralToken,
        SwapCollateralTokenToPnlToken
    }

    struct Props {
        Addresses addresses;
        Numbers numbers;
        Flags flags;
    }

    struct Addresses {
        address account;
        address receiver;
        address cancellationReceiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address initialCollateralToken;
        address[] swapPath;
    }

    struct Numbers {
        OrderType orderType;
        DecreasePositionSwapType decreasePositionSwapType;
        uint256 sizeDeltaUsd;
        uint256 initialCollateralDeltaAmount;
        uint256 triggerPrice;
        uint256 acceptablePrice;
        uint256 executionFee;
        uint256 callbackGasLimit;
        uint256 minOutputAmount;
        uint256 updatedAtTime;
        uint256 validFromTime;
    }

    struct Flags {
        bool isLong;
        bool shouldUnwrapNativeToken;
        bool isFrozen;
        bool autoCancel;
    }
}
