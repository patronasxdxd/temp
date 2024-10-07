// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IProposal {
    function executeProposal(address governance) external;
    function denied() external;
}

contract ProposalA is IProposal {

    uint256 value = 100;

    function denied() external override {
        selfdestruct(payable(address(0)));
    }

      function executeProposal(address governance) external override {
        Governance(governance).setValue(value);
    }
}

contract Governance {

    mapping(address => bool) public approvedProposals;
    address public owner;
    uint256 public value = 50;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyApproved() {
        require(approvedProposals[msg.sender], "Not an approved proposal");
        _;
    }

    function approveProposal(address proposalAddress) external onlyOwner {
        approvedProposals[proposalAddress] = true;
    }

    function denyProposal(address proposalAddress) external onlyOwner {
        IProposal proposedContract = IProposal(proposalAddress);
        proposedContract.denied();
    }

    function executeProposal(address proposalAddress) external {
        require(approvedProposals[proposalAddress], "Proposal not approved");
        IProposal(proposalAddress).executeProposal(address(this));
        delete approvedProposals[proposalAddress];

    }

    function setValue(uint256 _value) external onlyApproved {
        value = _value;
    }

    function getValue() public returns (uint256) {
        return value;
    }

    function solved() public returns (bool) {
        return value > 100;
    }
}
