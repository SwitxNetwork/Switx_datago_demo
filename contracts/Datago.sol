pragma solidity ^0.4.18;

import "./Owner.sol";

contract Datago is Owner{

    //struct
    struct Dmart{
        uint id;
        address provider;
        address buyer;
        string name;
        uint amountOfData;
        string description;
        uint256 price;
    }
    mapping (uint => Dmart) public dmarts;
  uint DataCounter;

    event LogSellData(
    uint indexed _id,
    address indexed _provider,
    string _name,
    uint _amountOfData,
    uint256 _price
  );

    event LogBuyData(
    uint indexed _id,
    address indexed _provider,
    address indexed _buyer,
    string _name,
    uint _amountOfData,
    uint256 _price
  );
    function kill() public onlyOwner {
    selfdestruct(owner);
  }
    function sellData(string _name,  uint _amountOfData, string _description, uint256 _price) public {
    // a new data to sell
    DataCounter++;

    // stores the data
    dmarts[DataCounter] = Dmart(
      DataCounter,
      msg.sender,
      0x0,
      _name,
      _amountOfData,
      _description,
      _price
    );

    LogSellData(DataCounter, msg.sender, _name, _amountOfData, _price);
  }

  //holds and returns number of data in Datago
  function getNumberOfData() public view returns (uint) {
    return DataCounter;
  }

    // fetch and return all Data IDs for Data still for available sale
  function getDataForSale() public view returns (uint[]) {
    // prepare output array
    uint[] memory dataIds = new uint[](DataCounter);

    uint numberOfDataForSale = 0;
    // iterate over the available data
    for(uint i = 1; i <= DataCounter;  i++) {
      // keep the ID if the data is still not sold
      if(dmarts[i].buyer == 0x0) {
        dataIds[numberOfDataForSale] = dmarts[i].id;
        numberOfDataForSale++;
      }
    }
        // copy the dataeIds array into a smaller forSale array
    uint[] memory forSale = new uint[](numberOfDataForSale);
    for(uint j = 0; j < numberOfDataForSale; j++) {
      forSale[j] = dataIds[j];
    }
    return forSale;
  }
  function buyData(uint _id) payable public {
    // we check whether there is an available data  for sale
    require(DataCounter > 0);

    // we check that the data exists
    require(_id > 0 && _id <= DataCounter);

    // we retrieve the data input from the blockchain
    Dmart storage mData = dmarts[_id];

    // we check that the data  is still on sale
    require(mData.buyer == 0X0);

    // we don't allow the provider to buy his own data from 
    require(msg.sender != mData.provider);

    // we check that the value sent corresponds to the price of the data for sale
    require(msg.value == mData.price);

    // keep buyer's information
    mData.buyer = msg.sender;

    // the buyer can pay the provider
    mData.provider.transfer(msg.value);

    // trigger the event
    LogBuyData(_id, mData.provider, mData.buyer, mData.name, mData.amountOfData , mData.price);
  }
}
