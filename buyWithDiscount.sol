pragma solidity ^0.8.4;

contract ContractB{
    
mapping(address => uint) AddrMap;    
address[] private Accounts;
address owner;

event PaymentDone(address sender,uint value);

function useDiscountAndDelete(address payable _address,uint DiscountRequest) public payable{
    require(DiscountRequest <= AddrMap[_address],"Balance not sufficent");
    AddrMap[_address] -= DiscountRequest;
    _address.transfer(DiscountRequest);
    emit PaymentDone(msg.sender,msg.value);

}


function payAndRequestDiscount(address _address,uint DiscountRequest) public payable{
    addAddress(_address);
    addDiscount(_address,DiscountRequest);
}

function addDiscount(address _address,uint _discountRequest) internal{
    AddrMap[_address] += _discountRequest;
}

function GetDiscount(address _address) public view returns(uint){
    return AddrMap[_address];
}

function CheckIfAddressExists(address _address) private view returns (bool){
    for (uint i = 0; i<Accounts.length;i++){
            if(Accounts[i]== _address)
                return true;}
    return false;
}

function addAddress(address _address) internal{
    if(!CheckIfAddressExists(_address)){
        Accounts.push(_address);
    }
}

function ContractBalance() public view returns(uint){
    return address(this).balance;
}

function getBalanceInEther() external view returns(uint){
        return address(this).balance/10**18;
    }

function getAccounts() external view returns(address[] memory){
    return Accounts;
}
}


//Questo contratto deve ricevere i pagamenti in cui calcolare lo sconto e quelli in cui si vuole consumare uno sconto

contract contractA{
    
    address private Storage_address;
    
    uint actualDiscount;
    
    address _owner = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    
    
    function payRequireDiscount(address payable _address)  amountAboveZero(msg.value) validAddress(_address) external payable{
        require(_address != address(0));
        require(msg.value > 0);
        ContractB StorageContract = ContractB(Storage_address);
        uint calcDiscount = msg.value*actualDiscount/100;
        StorageContract.payAndRequestDiscount{value: calcDiscount}(_address,calcDiscount);
    }
    
    function payAndApplyDiscount(address payable _address,uint RequestedDiscount) amountAboveZero(msg.value) validAddress(_address) external payable{
        require(msg.value >0);
        ContractB StorageContract = ContractB(Storage_address);
        StorageContract.useDiscountAndDelete(_address,RequestedDiscount);
    }
    
    modifier OnlyOwnerof(){
        require(msg.sender == _owner);
        _;
    }
    
    modifier amountAboveZero(uint _amount){
        require(_amount != 0);
        _;
    }
    
    modifier validAddress(address _address){
        require(_address != address(0));
        _;
    }
    
    function setStorageContract(address _address) external OnlyOwnerof{
        Storage_address = _address;
    }
    
    function getStorageContract() external view returns(address){
        return Storage_address;
    }
    
    function SetDiscount(uint _discount) external OnlyOwnerof{
        actualDiscount = _discount;
    }
    
    function getCurrentDiscount() external view returns(uint){
        return actualDiscount;
    }
    
    function getBalance() external OnlyOwnerof view returns(uint){
        return address(this).balance;
    }
    
    
}