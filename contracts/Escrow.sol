//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _id) external;
}

contract Escrow {

    address public nftAddress;
    uint256 public nftID;
    uint256 public purchasePrice;
    uint256 public escrowAmount;
    address payable public seller;
    address payable public buyer;
    address public inspector;
    address public lender;


    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this method");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }

    bool public inspectionPasssed = false;
    mapping(address => bool) public approval;


    constructor(address _nftAddress, uint256 _nftID, uint256 _purchasePrice, uint256 _escrowAmount, address payable _seller, address payable _buyer,  address _inspector, address _lender) {
        nftAddress = _nftAddress;
        nftID = _nftID;
        purchasePrice = _purchasePrice;
        escrowAmount = _escrowAmount;
        seller = _seller;
        buyer = _buyer;
        inspector = _inspector;
        lender = _lender;
    }

    // Put Under Contract (only buyer - payable escrow)
    function depositEarnest() public payable onlyBuyer {
        require(msg.value >= escrowAmount);
    }

    // Update Inspection Status (only inspector)
    function updateInspectionStatus(bool _passed) public onlyInspector {
        inspectionPasssed = _passed;
    }

    // Approve Sale
    function approveSale() public {
        approval[msg.sender] = true;
    }

    // Finalize Sale
    // -> Require inspection status (add more items here, like appraisal)
    // -> Require sale to be authorized
    // -> Require funds to be correct amount
    // -> Transfer NFT to buyer
    // -> Transfer Funds to Seller
    function finalizeSale() public {
        require(inspectionPasssed);
        require(approval[buyer]);
        require(approval[seller]);
        require(approval[lender]);
        require(address(this).balance >= purchasePrice);

        (bool success, ) = payable(seller).call{value: address(this).balance}("");
        require(success);

        IERC721(nftAddress).transferFrom(seller, buyer, nftID);
    }

    // Cancel Sale (handle earnest deposit)
    // -> if inspection status is not approved, then refund, otherwise send to seller
    function cancelSale() public {
        if(inspectionPasssed == false) {
            payable(buyer).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }

    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
