
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

/**
 * @title MangroveCarbonToken (TTF)
 * @notice Blue-Carbon TTF (Manglar Tumbes) — Transferable Tokenized Framework.
 *         Converts MRV-verified mangrove restoration data into on-chain
 *         blue carbon credits (tCO2eq), with automatic revenue distribution
 *         to coastal communities, platform upkeep, MRV verification, and
 *         nursery reinvestment. Designed to be deployed per-jurisdiction
 *         (Peru / Ecuador / Colombia) on the LACNet Open Pro-Testnet.
 */
contract MangroveCarbonToken is ERC20, AccessControl, ERC2771Context {

    // ---------------------------------------------------------------
    // ROLES
    // ---------------------------------------------------------------
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    // Verifiers = MRV specialists / automated drone-satellite oracles
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    // ---------------------------------------------------------------
    // JURISDICTIONS (multijurisdictional design: Peru, Ecuador, Colombia)
    // ---------------------------------------------------------------
    enum Jurisdiction { Peru, Ecuador, Colombia }

    // ---------------------------------------------------------------
    // MRV RESTORATION RECORDS (the on-chain audit trail)
    // ---------------------------------------------------------------
    struct RestorationRecord {
        address cooperative;     // wallet of the coastal cooperative
        uint256 hectares;        // hectares verified in this event (x100 for 2 decimals, e.g. 4000 = 40.00 ha)
        uint256 tCO2eqMinted;    // total TTF minted for this event
        Jurisdiction jurisdiction;
        string ipfsHash;         // pinned drone/satellite MRV evidence
        uint256 timestamp;
    }

    mapping(uint256 => RestorationRecord) public restorationRecords;
    uint256 public recordCount;

    // ---------------------------------------------------------------
    // REVENUE DISTRIBUTION (matches the report: 55 / 20 / 15 / 10)
    // ---------------------------------------------------------------
    address public technologyTreasury;      // 20% — platform upkeep
    address public mrvVerificationTreasury; // 15% — MRV verification costs
    address public nurseryTreasury;         // 10% — mangrove nursery reinvestment
    // NOTE: the remaining 55% mints directly to the cooperative's own wallet,
    // so no separate "coastal communities" treasury address is needed.

    uint256 public constant COMMUNITIES_SHARE_BPS = 5500; // 55.00%
    uint256 public constant TECH_SHARE_BPS        = 2000; // 20.00%
    uint256 public constant MRV_SHARE_BPS         = 1500; // 15.00%
    uint256 public constant NURSERY_SHARE_BPS     = 1000; // 10.00%
    // BPS = basis points; 10000 BPS = 100%

    // ---------------------------------------------------------------
    // EVENTS
    // ---------------------------------------------------------------
    event RestorationVerified(
        uint256 indexed recordId,
        address indexed cooperative,
        uint256 hectares,
        uint256 tCO2eqMinted,
        Jurisdiction jurisdiction,
        string ipfsHash
    );
    event CreditsRedeemed(address indexed redeemer, uint256 amount, string action);

    // ---------------------------------------------------------------
    // CONSTRUCTOR
    // ---------------------------------------------------------------
    constructor(
        address _technologyTreasury,
        address _mrvVerificationTreasury,
        address _nurseryTreasury,
        address _trustedForwarder // gasless meta-transaction forwarder (BaseRelayRecipient-style)
    )
        ERC20("Blue-Carbon TTF", "TTF")
        ERC2771Context(_trustedForwarder)
    {
        require(_technologyTreasury != address(0), "Invalid tech treasury");
        require(_mrvVerificationTreasury != address(0), "Invalid MRV treasury");
        require(_nurseryTreasury != address(0), "Invalid nursery treasury");

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _msgSender());
        _grantRole(VERIFIER_ROLE, _msgSender()); // deployer starts as first verifier

        technologyTreasury = _technologyTreasury;
        mrvVerificationTreasury = _mrvVerificationTreasury;
        nurseryTreasury = _nurseryTreasury;
    }

    // ---------------------------------------------------------------
    // ROLE MANAGEMENT
    // ---------------------------------------------------------------
    function addVerifier(address verifier) external onlyRole(ADMIN_ROLE) {
        grantRole(VERIFIER_ROLE, verifier);
    }

    function removeVerifier(address verifier) external onlyRole(ADMIN_ROLE) {
        revokeRole(VERIFIER_ROLE, verifier);
    }

    // ---------------------------------------------------------------
    // CORE FUNCTION: mint TTF after MRV-verified restoration
    // ---------------------------------------------------------------
    /**
     * @notice Called by an authorized verifier once drone/satellite MRV data
     *         confirms restored hectares. Automatically splits and mints the
     *         resulting TTF credits across all four stakeholders.
     * @param cooperative   Wallet address of the coastal cooperative.
     * @param hectares      Hectares verified (scaled by 100 for 2 decimals).
     * @param tCO2eqAmount  Total TTF (tCO2eq) to mint for this event.
     * @param jurisdiction  Peru, Ecuador, or Colombia.
     * @param ipfsHash      IPFS hash of the drone/satellite verification data.
     */
    function mintVerifiedCredits(
        address cooperative,
        uint256 hectares,
        uint256 tCO2eqAmount,
        Jurisdiction jurisdiction,
        string calldata ipfsHash
    ) external onlyRole(VERIFIER_ROLE) {
        require(cooperative != address(0), "Invalid cooperative address");
        require(tCO2eqAmount > 0, "Amount must be positive");

        recordCount++;
        restorationRecords[recordCount] = RestorationRecord({
            cooperative: cooperative,
            hectares: hectares,
            tCO2eqMinted: tCO2eqAmount,
            jurisdiction: jurisdiction,
            ipfsHash: ipfsHash,
            timestamp: block.timestamp
        });

        uint256 communitiesAmount = (tCO2eqAmount * COMMUNITIES_SHARE_BPS) / 10000;
        uint256 techAmount        = (tCO2eqAmount * TECH_SHARE_BPS) / 10000;
        uint256 mrvAmount         = (tCO2eqAmount * MRV_SHARE_BPS) / 10000;
        // remainder (avoids rounding dust from integer division) goes to nursery
        uint256 nurseryAmount     = tCO2eqAmount - communitiesAmount - techAmount - mrvAmount;

        _mint(cooperative, communitiesAmount);
        _mint(technologyTreasury, techAmount);
        _mint(mrvVerificationTreasury, mrvAmount);
        _mint(nurseryTreasury, nurseryAmount);

        emit RestorationVerified(recordCount, cooperative, hectares, tCO2eqAmount, jurisdiction, ipfsHash);
    }

    // ---------------------------------------------------------------
    // 3R CIRCULAR ECONOMY ACTIONS (matches the dashboard's action panel)
    // ---------------------------------------------------------------

    /// @notice REDUCE: corporations/individuals burn TTF to offset verified emissions.
    function offsetEmissions(uint256 amount) external {
        _burn(_msgSender(), amount);
        emit CreditsRedeemed(_msgSender(), amount, "Reduce: Corporate Offset");
    }

    /// @notice RECYCLE: cooperatives redeem TTF for ecotourism or fishing-quota access.
    ///         Tokens are transferred (not burned) into the nursery treasury,
    ///         effectively reinvesting redemption value into restoration.
    function redeemForAccess(uint256 amount, string calldata accessType) external {
        _transfer(_msgSender(), nurseryTreasury, amount);
        emit CreditsRedeemed(_msgSender(), amount, string(abi.encodePacked("Recycle: ", accessType)));
    }

    // ---------------------------------------------------------------
    // VIEW HELPERS
    // ---------------------------------------------------------------
    function getRestorationRecord(uint256 recordId) external view returns (RestorationRecord memory) {
        return restorationRecords[recordId];
    }

    // ---------------------------------------------------------------
    // ERC2771Context / gasless meta-transaction overrides
    // (required boilerplate whenever ERC2771Context is combined with
    //  another base contract that also defines _msgSender/_msgData)
    // ---------------------------------------------------------------
    function _msgSender() internal view override(Context, ERC2771Context) returns (address) {
        return ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    function _contextSuffixLength() internal view override(Context, ERC2771Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength();
    }
}
