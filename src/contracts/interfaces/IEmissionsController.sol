// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0;

/// @title IEmissionsControllerErrors
/// @notice Errors for the IEmissionsController contract.
interface IEmissionsControllerErrors {
    // TODO: Define with implementation.
}

/// @title IEmissionsControllerTypes
/// @notice Types for the IEmissionsController contract.
interface IEmissionsControllerTypes {
    /// @notice Distribution types as defined in the ELIP.
    /// @dev Ref: "Distribution Submission types may include: createRewardsForAllEarners, createOperatorSetTotalStakeRewardsSubmission, createOperatorSetUniqueStakeRewardsSubmission, EigenDA Distribution, Manual Distribution."
    enum DistributionType {
        RewardsForAllEarners,
        OperatorSetTotalStake,
        OperatorSetUniqueStake,
        EigenDA,
        Manual
    }

    /// @notice A Distribution structure containing weight, type and strategies.
    /// @dev Ref: "A Distribution consists of N fields: Weight, Distribution-type, Strategies and Multipliers."
    struct Distribution {
        uint256 weight;
        DistributionType distributionType;
        bytes strategiesAndMultipliers;
    }

    /// @notice Configuration for the EmissionsController.
    /// @dev Ref: "The amount of EIGEN minted weekly (inflation rate) is set by governance..."
    struct EmissionsConfiguration {
        uint256 inflationRate;
        uint256 startTime;
        uint256 cooldownSeconds;
    }
}

/// @title IEmissionsControllerEvents
/// @notice Events for the IEmissionsController contract.
interface IEmissionsControllerEvents is IEmissionsControllerTypes {
    /// @notice Emitted when a distribution is updated.
    event DistributionUpdated(uint256 indexed index, Distribution distribution);

    /// @notice Emitted when a distribution is added.
    event DistributionAdded(uint256 indexed index, Distribution distribution);
    
    /// @notice Emitted when a distribution is removed.
    event DistributionRemoved(uint256 indexed index);
    
    /// @notice Emitted when the Incentive Council address is updated.
    event IncentiveCouncilUpdated(address indexed newCouncil);

    /// @notice Emitted when the inflation rate is updated.
    event InflationRateUpdated(uint256 newRate);
}

/// @title IEmissionsController
/// @notice Interface for the EmissionsController contract, which acts as the upgraded ActionGenerator.
/// @dev Ref: "This proposal requires upgrades to the TokenHopper and Action Generator contracts."
interface IEmissionsController is IEmissionsControllerErrors, IEmissionsControllerEvents {
    /// @notice Initializes the contract.
    function initialize(
        address incentiveCouncil,
        uint256 inflationRate,
        uint256 startTime,
        uint256 cooldownSeconds
    ) external;

    /// -----------------------------------------------------------------------
    /// Permissionless Trigger
    /// -----------------------------------------------------------------------

    /// @notice Triggers the weekly emissions.
    /// @dev Ref: "The ActionGenerator today is a contract ... that is triggered by the Hopper. When triggered, it mints new EIGEN tokens..."
    /// @dev Permissionless function that can be called by anyone when `canPress()` returns true.
    function pressButton() external;

    /// @notice Checks if the emissions can be triggered.
    /// @return True if the cooldown has passed and the system is ready.
    function canPress() external view returns (bool);

    /// -----------------------------------------------------------------------
    /// Protocol Council Functions
    /// -----------------------------------------------------------------------

    /// @notice Sets the Incentive Council address.
    /// @dev Only the Protocol Council can call this function.
    /// @dev Ref: "Protocol Council Functions: Set Incentive Council multisig address that can interface with the ActionGenerator..."
    /// @param incentiveCouncil The new Incentive Council address.
    function setIncentiveCouncil(address incentiveCouncil) external;

    /// @notice Sets the inflation rate (EIGEN minted per week).
    /// @dev Only the Protocol Council can call this function.
    /// @dev Ref: "Protocol Council Functions: Modification of the top level token emission as a proportion of supply annually... on a timelock"
    /// @param inflationRate The new inflation rate.
    function setInflationRate(uint256 inflationRate) external;

    /// -----------------------------------------------------------------------
    /// Incentive Council Functions
    /// -----------------------------------------------------------------------

    /// @notice Adds a new distribution.
    /// @dev Only the Incentive Council can call this function.
    /// @dev Ref: "Incentive Council Functions: addDistribution(weight{int}, distribution-type{see below}, strategiesAndMultipliers())"
    /// @param weight The weight of the distribution.
    /// @param distributionType The type of distribution.
    /// @param strategiesAndMultipliers Encoded strategies and multipliers.
    function addDistribution(
        uint256 weight,
        DistributionType distributionType,
        bytes calldata strategiesAndMultipliers
    ) external;

    /// @notice Updates an existing distribution.
    /// @dev Only the Incentive Council can call this function.
    /// @dev Ref: "Incentive Council Functions: updateDistribution(index)"
    /// @param index The index of the distribution to update.
    /// @param weight The new weight of the distribution.
    /// @param distributionType The new type of distribution.
    /// @param strategiesAndMultipliers The new encoded strategies and multipliers.
    function updateDistribution(
        uint256 index,
        uint256 weight,
        DistributionType distributionType,
        bytes calldata strategiesAndMultipliers
    ) external;

    /// @notice Removes a distribution.
    /// @dev Only the Incentive Council can call this function.
    /// @dev Ref: Implied by "updateDistribution" and general management of distributions.
    /// @param index The index of the distribution to remove.
    function removeDistribution(uint256 index) external;

    /// -----------------------------------------------------------------------
    /// View
    /// -----------------------------------------------------------------------

    /// @notice Returns a distribution by index.
    /// @param index The index of the distribution.
    /// @return The Distribution struct at the given index.
    function getDistribution(uint256 index) external view returns (Distribution memory);

    /// @notice Returns all distributions.
    /// @return An append-only array of Distribution structs.
    function getDistributions() external view returns (Distribution[] memory);

    /// @notice Returns the current Incentive Council address.
    /// @return The Incentive Council address.
    function getIncentiveCouncil() external view returns (address);

    /// @notice Returns the current configuration.
    /// @return The EmissionsConfiguration struct.
    function getEmissionsConfiguration() external view returns (EmissionsConfiguration memory);
}
