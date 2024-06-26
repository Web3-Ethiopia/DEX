interface IQuotationFetch {

    stract Quotation {
        uint256 id;
        string quotation;
    }


    Quotation[] public quotations;
    uint256 quotationId;


    // map the quotation id to the quotation
    // map the id to the quotation id 
    mapping(id => _quotationId) quotations;
    mapping(uint256 => string) quotations;


    constructor() public {    // inchalalize the quotation id
    }
        quotationId = 0;  

    function addQuotation (string memory _quotation) public {
        quotations[quotationId] = _quotation;
        quotationId++;
    }


    function getQuotation(uint256 _quotationId) external view returns (string memory){    //  get quotation
        return quotations[_quotationId];        

    }
    
    function createQuotation(string calldata _quotation) external returns (uint256);{        // create a logic for the create quotation


        Quotation memory newQuotation = Quotation({
            id: quotations.length,
            quotation: _quotation
        });
        
        quotations[newQuotation.id] = newQuotation;
        return newQuotation.id;
    }


    function updateQuotation(uint256 _quotationId, string calldata _quotation) external{    //create a logic for the update quotation

        

    }

    function deleteQuotation(uint256 _quotationId) external; {        // create a logic for the delete quotation
            
        delete quotations[_quotationId];

    }
    
}