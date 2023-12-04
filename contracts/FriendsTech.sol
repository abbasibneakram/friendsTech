//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract FriendtechSharesV1 is Ownable {
    IERC20 techSharesToken;
    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public subjectFeePercent;
    address partyA = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address partyB = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address partyC = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

    event Trade(address trader, address subject, bool isBuy, uint256 shareAmount, uint256 ethAmount, uint256 protocolEthAmount, uint256 subjectEthAmount, uint256 supply);

    // SharesSubject => (Holder => Balance)
    mapping(address => mapping(address => uint256)) public sharesBalance;

    // SharesSubject => Supply
    mapping(address => uint256) public sharesSupply;

    constructor(address _techSharesToken){
        techSharesToken = IERC20(_techSharesToken);
    }

    function setFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
        subjectFeePercent = _feePercent;
    }

    function getPrice(uint256 supply, uint256 amount) public pure returns (uint256) {
        uint256 sum1 = supply == 0 ? 0 : (supply - 1 )* (supply) * (2 * (supply - 1) + 1) / 6;
        uint256 sum2 = supply == 0 && amount == 1 ? 0 : (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6;
        uint256 summation = sum2 - sum1;
        return summation * 1 ether / 16000;
    }

    function getBuyPrice(address sharesSubject, uint256 amount) public view returns (uint256) {
        return getPrice(sharesSupply[sharesSubject], amount);
    }

    function getSellPrice(address sharesSubject, uint256 amount) public view returns (uint256) {
        return getPrice(sharesSupply[sharesSubject] - amount, amount);
    }

    function getBuyPriceAfterFee(address sharesSubject, uint256 amount) public view returns (uint256) {
        uint256 price = getBuyPrice(sharesSubject, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        return price + protocolFee + subjectFee;
    }

    function getSellPriceAfterFee(address sharesSubject, uint256 amount) public view returns (uint256) {
        uint256 price = getSellPrice(sharesSubject, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        return price - protocolFee - subjectFee;
    }

    //function to calculate parties dividend
    function calculateFee(uint256 _totalFee) internal pure returns(uint256,uint256,uint256,uint256) {
        uint256 thirdPertiesFee = (_totalFee * 10)/100;
        uint256 protocolShare = _totalFee - thirdPertiesFee;
        uint256 partyAfee = (thirdPertiesFee * 4)/100;
        uint256 partyBfee = (thirdPertiesFee * 4)/100;
        uint256 partyCfee = (thirdPertiesFee * 2)/100; 
        return (protocolShare,partyAfee,partyBfee,partyCfee);
    }

    // Removed payable keyword to not pay ETH for buying
    function buyShares(address sharesSubject, uint256 amount) public {
        uint256 supply = sharesSupply[sharesSubject];
        require(supply > 0 || sharesSubject == msg.sender, "Only the shares' subject can buy the first share");
        uint256 price = getPrice(supply, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        //Checked for approval of amount to contract
        require(techSharesToken.allowance(msg.sender,address(this)) >= price + protocolFee + subjectFee, "Tokens not approved!" );
         // Checked the user's token balance
        require(techSharesToken.balanceOf(msg.sender) >= price + protocolFee + subjectFee, "Insufficient token balance");
         // Transferred tokens from the user to the contract
        techSharesToken.transferFrom(msg.sender, address(this), price + protocolFee + subjectFee);

        // Fee calculation for different parties
        (uint256 protocolShare, uint256 partyAfee,  uint256 partyBfee, uint256 partyCfee)  = calculateFee(protocolFee);

        sharesBalance[sharesSubject][msg.sender] = sharesBalance[sharesSubject][msg.sender] + amount;
        sharesSupply[sharesSubject] = supply + amount;

        //Fee Distribution in ERC20 Token
        techSharesToken.transfer(partyA, partyAfee);
        techSharesToken.transfer(partyB, partyBfee);
        techSharesToken.transfer(partyC, partyCfee);
        techSharesToken.transfer(protocolFeeDestination,protocolShare);
        techSharesToken.transfer(sharesSubject,subjectFeePercent);
       
    }

    // Removed payable keyword as there is no need to pay ETH in sell function
    function sellShares(address sharesSubject, uint256 amount) public {
        uint256 supply = sharesSupply[sharesSubject];
        require(supply > amount, "Cannot sell the last share");
        uint256 price = getPrice(supply - amount, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        require(sharesBalance[sharesSubject][msg.sender] >= amount, "Insufficient shares");
        sharesBalance[sharesSubject][msg.sender] = sharesBalance[sharesSubject][msg.sender] - amount;
        sharesSupply[sharesSubject] = supply - amount;
        emit Trade(msg.sender, sharesSubject, false, amount, price, protocolFee, subjectFee, supply - amount);

        // Fee calculation for different parties
        (uint256 protocolShare, uint256 partyAfee,  uint256 partyBfee, uint256 partyCfee)  = calculateFee(protocolFee);

        // Share Amount transfer to function callee
        techSharesToken.transfer(msg.sender,price - protocolFee - subjectFee);

        //Fee Distribution in ERC20 Token
        techSharesToken.transfer(partyA, partyAfee);
        techSharesToken.transfer(partyB, partyBfee);
        techSharesToken.transfer(partyC, partyCfee);
        techSharesToken.transfer(protocolFeeDestination,protocolShare);
        techSharesToken.transfer(sharesSubject,subjectFeePercent);
    }
}