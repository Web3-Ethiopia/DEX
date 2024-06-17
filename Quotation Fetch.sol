//SPDX-LICENSE-IDENTIFIER:UNLICENSED;
pragma solidity 0.5.11;
contract QuotationFetch {
    // Mapping of quotation IDs to quotation structures
    mapping (uint256 => Quotation) public quotations;

    // Struct for a quotation
    struct Quotation {
        address recipient;
        uint256[] items;
        uint256[] rates;
        uint256[] taxes;
        uint256 validity;
        uint256 deliveryTime;
        string[] conditions;
    }

    // Function to create a new quotation
    function createQuotation(
        address _recipient,
        uint256[] memory _items,
        uint256[] memory _rates,
        uint256[] memory _taxes,
        uint256 _validity,
        uint256 _deliveryTime,
        string[] memory _conditions
    ) public {
        // Create a new quotation and store it in the mapping
        uint256 quotationId = uint256(keccak256(abi.encodePacked(_recipient, _items, _rates, _taxes, _validity, _deliveryTime, _conditions)));
        quotations[quotationId] = Quotation(_recipient, _items, _rates, _taxes, _validity, _deliveryTime, _conditions);
    }

    // Function to update an existing quotation
    function updateQuotation(
        uint256 _quotationId,
        address _newRecipient,
        uint256[] memory _newItems,
        uint256[] memory _newRates,
        uint256[] memory _newTaxes,
        uint256 _newValidity,
        uint256 _newDeliveryTime,
        string[] memory _newConditions
    ) public {
        // Update the quotation in the mapping
        quotations[_quotationId].recipient = _newRecipient;
        quotations[_quotationId].items = _newItems;
        quotations[_quotationId].rates = _newRates;
        quotations[_quotationId].taxes = _newTaxes;
        quotations[_quotationId].validity = _newValidity;
        quotations[_quotationId].deliveryTime = _newDeliveryTime;
        quotations[_quotationId].conditions = _newConditions;
    }

    // Function to retrieve a specific quotation
    function getQuotation(uint256 _quotationId) public view returns (address, uint256, uint256, uint256, uint256, uint256, string,) {
        // Retrieve the quotation from the mapping
        Quotation memory quotation = quotations[_quotationId];
        return (
            quotation.recipient,
            quotation.items,
            quotation.rates,
            quotation.taxes,
            quotation.validity,
            quotation.deliveryTime,
            quotation.conditions
        );
    }

    // Function to submit a quotation
    function submitQuotation(uint256 _quotationId) public {
        // Mark the quotation as submitted
        quotations[_quotationId].submitted = true;
    }

    // Function to set a quotation as lost
    function setAsLost(uint256 _quotationId) public {
        // Mark the quotation as lost
        quotations[_quotationId].lost = true;
    }
}