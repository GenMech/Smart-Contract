// SPDX-License-Identifier: MIT
// 0xF2893d1112b11c73e434dD6767240e50bc9465AB
pragma solidity ^0.8.17;

pragma experimental ABIEncoderV2;

contract MyContract {
    address public owner;

    struct CodeObj {
        uint status;
        string brand;
        string model;
        string description;
        string manufactuerName;
        string manufactuerLocation;
        string manufactuerTimestamp;
        string retailer;
        string[] customers;
        address myAdd;
    }

    struct CustomerObj {
        string name;
        string phone;
        string[] code;
        bool isValue;
        address myAdd;
    }

    struct ManufactureObj{
        address myAdd;
        string name;
        string location;
    }

    struct RetailerObj {
        string name;
        string location;
        address myAdd;
    }

    mapping(string => CodeObj) public codeArr;
    mapping(string => CustomerObj) public customerArr;
    mapping(string => RetailerObj) public retailerArr;
    mapping(address => ManufactureObj) public manufactureArr;

    modifier onlyOwner {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function createCode(
        address manufactureAdd,
        string memory _code,
        string memory _brand,
        string memory _model,
        uint _status,
        string memory _description,
        string memory _manufactuerTimestamp
    ) public returns (uint) {
        CodeObj memory newCode;
        newCode.brand = _brand;
        newCode.model = _model;
        newCode.status = _status;
        newCode.description = _description;
        newCode.manufactuerName = manufactureArr[manufactureAdd].name;
        newCode.manufactuerLocation =  manufactureArr[manufactureAdd].location;
        newCode.manufactuerTimestamp = _manufactuerTimestamp;
        newCode.myAdd = manufactureAdd;
        codeArr[_code] = newCode;
        return 1;
    }

    function getNotOwnedCodeDetails(string memory _code) public view returns (string memory, string memory, uint, string memory, string memory, string memory, string memory) {
        return (
            codeArr[_code].brand,
            codeArr[_code].model,
            codeArr[_code].status,
            codeArr[_code].description,
            codeArr[_code].manufactuerName,
            codeArr[_code].manufactuerLocation,
            codeArr[_code].manufactuerTimestamp
        );
    }

    function getOwnedCodeDetails(string memory _code) public view returns (string memory, string memory, address) {
        return (retailerArr[codeArr[_code].retailer].name, retailerArr[codeArr[_code].retailer].location, retailerArr[codeArr[_code].retailer].myAdd);
    }

    function addRetailerToCode(address currAdd, string memory _code, string memory _hashedEmailRetailer) public returns (uint) {
        if(codeArr[_code].myAdd != currAdd){
            return 0;
        }
        codeArr[_code].retailer = _hashedEmailRetailer;
        codeArr[_code].myAdd = retailerArr[_hashedEmailRetailer].myAdd;
        return 1;
    }

    function createCustomer(address currAdd, string memory _hashedEmail, string memory _name, string memory _phone) public returns (bool) {
        if (customerArr[_hashedEmail].isValue) {
            return false;
        }
        CustomerObj memory newCustomer;
        newCustomer.name = _name;
        newCustomer.phone = _phone;
        newCustomer.isValue = true;
        newCustomer.myAdd = currAdd;
        customerArr[_hashedEmail] = newCustomer;
        return true;
    }

    function getCustomerDetails(string memory _code) public view returns (string memory, string memory, address) {
        return (customerArr[_code].name, customerArr[_code].phone, customerArr[_code].myAdd);
    }

    function createRetailer(address currAdd, string memory _hashedEmail, string memory _retailerName, string memory _retailerLocation) public returns (uint) {
        RetailerObj memory newRetailer;
        newRetailer.name = _retailerName;
        newRetailer.location = _retailerLocation;
        newRetailer.myAdd = currAdd;
        retailerArr[_hashedEmail] = newRetailer;
        return 1;
    }

    function createManufacture(address manuAdd, string memory name, string memory location) public returns (uint) {
        ManufactureObj memory newManufacture;
        newManufacture.name = name;
        newManufacture.location = location;
        newManufacture.myAdd = manuAdd;
        manufactureArr[manuAdd] = newManufacture;
        return 1;
    }

    function getRetailerDetails(string memory _code) public view returns (string memory, string memory, address) {
        return (retailerArr[_code].name, retailerArr[_code].location, retailerArr[_code].myAdd);
    }

    function reportStolen(string memory _code, string memory _customer) public returns (bool) {
        uint i;
        if (customerArr[_customer].isValue) {
            for (i = 0; i < customerArr[_customer].code.length; i++) {
                if (compareStrings(customerArr[_customer].code[i], _code)) {
                    codeArr[_code].status = 2;
                    return true;
                }
            }
        }
        return false;
    }

    function changeOwner(address currAdd, string memory _code, string memory _oldCustomer, string memory _newCustomer) public returns (bool) {
        uint i;
        bool flag = false;
        CodeObj storage product = codeArr[_code];
        if(product.myAdd != currAdd){
            return false;
        }

        if (customerArr[_oldCustomer].isValue && customerArr[_newCustomer].isValue) {
            for (i = 0; i < customerArr[_oldCustomer].code.length; i++) {
                if (compareStrings(customerArr[_oldCustomer].code[i], _code)) {
                    flag = true;
                    break;
                }
            }

            if (flag) {
                for (i = 0; i < product.customers.length; i++) {
                    if (compareStrings(product.customers[i], _oldCustomer)) {
                        codeArr[_code].customers[i] = _newCustomer;
                        codeArr[_code].myAdd = customerArr[_newCustomer].myAdd;
                        break;
                    }
                }

                for (i = 0; i < customerArr[_oldCustomer].code.length; i++) {
                    if (compareStrings(customerArr[_oldCustomer].code[i], _code)) {
                        remove(i, customerArr[_oldCustomer].code);
                        uint len = customerArr[_newCustomer].code.length;
                        if (len == 0) {
                            customerArr[_newCustomer].code.push(_code);
                            customerArr[_newCustomer].code.push("hack");
                        } else {
                            customerArr[_newCustomer].code[len - 1] = _code;
                            customerArr[_newCustomer].code.push("hack");
                        }
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function initialOwner(address currAdd, string memory _code, string memory _retailer, string memory _customer) public returns (bool) {
        if(currAdd != codeArr[_code].myAdd){
            return false;
        }

        if (compareStrings(codeArr[_code].retailer, _retailer) && customerArr[_customer].isValue) {
            codeArr[_code].customers.push(_customer);
            codeArr[_code].status = 1;
            codeArr[_code].myAdd = customerArr[_customer].myAdd;
            uint len = customerArr[_customer].code.length;
            if (len == 0) {
                customerArr[_customer].code.push(_code);
                customerArr[_customer].code.push("hack");
            } else {
                customerArr[_customer].code[len - 1] = _code;
                customerArr[_customer].code.push("hack");
            }
            return true;
        }
        return false;
    }

    function getCodes(string memory _customer) public view returns (string[] memory) {
        return customerArr[_customer].code;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function remove(uint index, string[] storage array) internal returns (bool) {
        if (index >= array.length) return false;
        for (uint i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        delete array[array.length - 1];
        array.pop();
        return true;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}
