/** 

Proph

http://ethereum.github.io/browser-solidity/#gist=b181f7926399e9ac0316fed613bf23c9
http://swarm-gateways.net/bzzr:/24c529bae32786a4a1ae4e02255b2d0c3d30a7f48775577eed2e76a246081994

solves my earlier question which is how to measure reviews/citations by using public programmatic proxy-authors « pprogxy » ( "ethereum blockchain cryptographic smart-contract" ) ; and also calls-for-papers [CFP] for the "formal verification" of these pprogxies , where the chosen reviews/citations-metric is through these same pprogxies !?1!

Outline : Primo, "review" and "citation" is the same thing and shall be costly and is similar to some current/currency/token. Secondo, the question of initialization (which is external) shall be de-coupled from the question of logic/current (which is internal) : the current is viewed through both basic-marketmulti-initialization and inductive/recursive/feedback-initialization. Tertio, reviews/citations is similar to some current/currency/token which flows downward from younger document-nodes to older document-nodes (which may refuse to receive/stake some too-diluted citation/token). Any document-node ("editor") which lastly-possesses some tokens, may sink/burn/erase these tokens into another upward (younger) document-node ("author"), which may mint/create/faucet only-half of those sinked-tokens on behalf of any other newly-created document-node ("reviewer") citing/towards it. Some record of all these transactions (sink or faucet or cite or mere-transfer) is memorized via internal storage and external log/trace events, such that after inputing some dilution-percentage of initially-sinked tokens at existing document-nodes then oneself may compute the dilution-percentage of the balance at each document-node and may compute the real-measure (ratio of sinked diluted-tokens over fauceted diluted-tokens) at each document-node. Finally some archive tool may integrate the common metadata content-address ("SHA hash") of each document-node along another content-addressable replicated-storage tool ("swarm DHT").

Alternative : Another initialization may simply-be to assume that the user-addresses (from some constant list) who own document-nodes are non-interdependent and then either (+) to prevent self-citation or (+) to limit the total number of new document-nodes created by each particular user-address (and later externally-iteratively/inductive-update these particular numbers). But non-interdependence is rare : [[http://retractionwatch.com/2017/08/22/one-way-boost-unis-ranking-ask-faculty-cite/]] [[https://scholarlykitchen.sspnet.org/2017/08/03/transparent-peer-review-mean-important/]] ... and it is common that reviewers flip-flop between : ( monetarist-or-tribalistic ) « possibility » ( "discretion" )   versus   ( monetarist-or-tribalistic ) « copy-me grade » ( "CV" , "objective" , refuse to be subjective-under-teaching ) ...

Formal verification : There are many alternatives from attempting to verify the intermediate-level assembly code. Primo, the transactions basic-accounting may be verified, where the high-level source-code already-is the specification. Secondo, the complex mathematical algorithms may be verified, where this verification is no-longer particular to the ethereum-virtual-machine. Tertio, that the hidden high-level source-code does compile to the public ethereum-virtual-machine-opcode/bytecode stored inside the blockchain, may be verified simply-by making this high-level source-code public. Quarto, practical-engineering hacks/sidechannels may only be verified-and-corrected over some long-time testing with smaller-stakes.

EASY REGISTRATION : Primo, download Chrome Metamask extension [[google.com/#q=Chrome+Metamask]] , select "Ropsten Test Net" , create new key , click "Buy" to get test tokens. Secondo, in the above "Browser Solidity" source-code page , select "Injected Web3" Environment , parse/compile and click "At Address for ¢entseCurrent" and input : 0xc7c6a7b7d396388127ce6140b39ca1eff3beb07b . Tertio, post the new review text in the above "Swarm Gateways" and get the content-address hash. Quarto, register this review metadata as some new pprogxy for the Centse currency.


-----

eth 0x54810dcb93b37DBE874694407f78959Fa222D920 , paypal 1337777.OOO@gmail.com , wechatpay 2796386464@qq.com , irc #OOO1337777

**/

pragma solidity ^0.4.15;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/Math.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/LimitedTransferToken.sol";

contract CentseCurrent is Ownable, StandardToken, LimitedTransferToken {
    event Mint(address rev_to, uint256 amount);
    mapping (address => uint) public ed_date;
    mapping (address => bytes32) public rev_swarmHash;
    mapping (address => uint) public rev_date;
    mapping (address => address) public rev_editor;
    event NewEditor(address _editor);
    event NewReview(address _review);
    enum HowCite { byCite , byFaucet , bySink }
    struct Cite {
        address rev_from;
    	address rev_pay;
    	uint256 cite_value;
    	uint64 centseCurrent_effective;
    	bool cancelable;
    	bool burnsOnCancel;
    	HowCite how; }
    mapping (address => Cite[]) public cites;
    event AddCite(address _rev_to, address _rev_from,  address _rev_pay, uint256 _cite_value, HowCite _how, uint256 _citeId);
    uint8 internal constant TWOCENTSE = 2;
    uint8 internal constant FAUCETAHEAD = 20;
    uint8 internal constant SINKED_OVER_FAUCET = 2;
    uint64 internal constant MIN_NONEFFECTIVE = 2 minutes; // 28 days;
    uint64 internal constant REVIEWSDELAY = 20 seconds; //2 days;

    modifier noCycle(address _rev_from , address _rev_to) {
        require(rev_date[_rev_to] > 0 && rev_date[_rev_from] > rev_date[_rev_to] + REVIEWSDELAY);
        _;
    }
        
    function transfer(address _rev_to, uint256 _cite_value) noCycle(msg.sender, _rev_to) public returns (bool) {
        revert();
    }
    
    function transferFrom(address _rev_from, address _rev_to, uint256 _cite_value) noCycle(_rev_from, _rev_to) returns (bool) {    
        return super.transferFrom(_rev_from, _rev_to, _cite_value);
    }

    function transferableTokens(address _holder, uint64 _time) constant public returns (uint256) {
        uint256 _cites_length = cites[_holder].length;

        if (_cites_length == 0) {
	        return super.transferableTokens(_holder, _time); 
	    }

        uint256 nonEffective = 0;

        for (uint256 i = 0; i < _cites_length; i++) {
            if (cites[_holder][i].how != HowCite.bySink && _time < cites[_holder][i].centseCurrent_effective) {
                nonEffective = SafeMath.add(nonEffective, cites[_holder][i].cite_value);
            }
        }

        uint256 this_transferableTokens = SafeMath.sub(balanceOf(_holder), nonEffective);
  	    return Math.min256(this_transferableTokens, super.transferableTokens(_holder, _time));
    }   
    
    function effectiveSinkedTokens(address _holder, uint64 _time) constant public returns (uint256 _sinked) {
        uint256 _cites_length = cites[_holder].length;

        for (uint256 i = 0; i < _cites_length; i++) {
            if (cites[_holder][i].how == HowCite.bySink && cites[_holder][i].centseCurrent_effective <= _time) {
                _sinked = SafeMath.add(_sinked, cites[_holder][i].cite_value);
            }
        }
    }   
    
    function allFaucetTokens(address _holder) constant public returns (uint256 _allfaucet) {
        uint256 _cites_length = cites[_holder].length;

        for (uint256 i = 0; i < _cites_length; i++) {
            if (cites[_holder][i].how == HowCite.byFaucet) {
                _allfaucet = SafeMath.add(_allfaucet, cites[_holder][i].cite_value);
            }
        }
    }
    
    function mint(address _rev_to, uint256 _amount) internal returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_rev_to] = balances[_rev_to].add(_amount);
        Mint(_rev_to, _amount);
        Transfer(0x0, _rev_to, _amount);
        return true;
    }         

    function newEditor(address _editor, uint _auctionStart, uint  _biddingTime, uint8  _outerTopic) returns (address editor_address) {
        Editor editor = new Editor(_editor, _auctionStart, _biddingTime, _outerTopic); 
        editor_address = address(editor);
        ed_date[editor_address] = block.timestamp;
    	NewEditor(editor_address);
    }
    
    function newReview(address _rev_to, string _rev_title, bytes32 _rev_swarmHash, uint8 _outerTopic, address _editor) public returns (address rev_address, bool won) {
         /** ALT: it is possible to require conditions such that msg.sender is contained only in some 
         * pre-defined constant list of non-interdependent user addresses and 
         * then either 1. refuse any self-citation or 
         * 2. limit the total number of new documents for each particular user address
         * and iteratively/inductive-update these particular numbers after the ouput of each round/period unit
         **/
        require (rev_date[_rev_to] > 0 && block.timestamp > rev_date[_rev_to] + REVIEWSDELAY);
        require (_editor == 0x0 || ed_date[_editor] > 0);
        Review rev = new Review(msg.sender, this, _rev_to, _rev_title, _rev_swarmHash, _outerTopic, _editor);
        rev_address = address(rev);
        rev_date[rev_address] = block.timestamp;
        rev_swarmHash[rev_address] = _rev_swarmHash;
        rev_editor[rev_address] = _editor;

        require(allFaucetTokens(_rev_to) <= effectiveSinkedTokens(_rev_to, uint64(block.timestamp)) / SINKED_OVER_FAUCET);
    	cites[rev_address].push(Cite(this, this, FAUCETAHEAD, uint64(block.timestamp) + MIN_NONEFFECTIVE, true /* false for no-admin */, true, HowCite.bySink));
        
        if (ed_date[_editor] > 0) {
            Editor editor = Editor(_editor);
            require (editor.confirmReview(msg.sender, _rev_to, _rev_title, _rev_swarmHash, _outerTopic)); 
        }
        
        mint(_rev_to, TWOCENTSE);
        cites[_rev_to].push(Cite(rev_address, _rev_to, TWOCENTSE, uint64(block.timestamp) + MIN_NONEFFECTIVE, true, true, HowCite.byFaucet));

        NewReview(rev_address);
    }
    
    function _addCite(address _rev_from, address _rev_to, uint16 _cite_value, uint64 _centseCurrent_effective, bool _cancelable, bool _burnsOnCancel) public {
        require (rev_date[_rev_to] > 0 && rev_date[_rev_from] > rev_date[_rev_to] + REVIEWSDELAY && rev_date[msg.sender] > 0);
    	require (uint64(block.timestamp) + MIN_NONEFFECTIVE <= _centseCurrent_effective);
    	address _rev_to_money = 0xdead;
    	HowCite _how = HowCite.bySink;
    	Review rev = Review(_rev_from);
    	require((_rev_from == msg.sender ) || (rev.isPendingCite(_rev_to, _cite_value, _centseCurrent_effective, _cancelable, _burnsOnCancel)));

    	if (ed_date[rev_editor[_rev_from]] > 0){
            Editor editor = Editor(rev_editor[_rev_from]);
            require (editor.confirmEditor(_rev_from, msg.sender, _rev_to)); }
        else {
            require (rev_date[msg.sender] > rev_date[_rev_to] + REVIEWSDELAY );
            _rev_to_money = _rev_to;
            _how = HowCite.byCite;
        }

    	uint256 _count = cites[_rev_to].push(Cite(_rev_from, msg.sender, _cite_value, _centseCurrent_effective, true /*_cancelable*/, _burnsOnCancel, _how));
    	super.transfer(_rev_to_money, _cite_value);
    	AddCite(_rev_to_money, _rev_from, msg.sender, _cite_value, _how, _count - 1);
    }
    
    function _cancelCite(address _rev_to, uint256 _citeId) public {
    	Cite storage _cite = cites[_rev_to][_citeId];
	    require (_cite.cancelable && (_cite.rev_pay == msg.sender || _rev_to == msg.sender));
    	address _rev_pay_money = _cite.burnsOnCancel ? 0xdead : _cite.rev_pay;
    
    	if (now <= _cite.centseCurrent_effective) {
            delete cites[_rev_to][_citeId];
       	    cites[_rev_to][_citeId] = cites[_rev_to][cites[_rev_to].length.sub(1)];
            cites[_rev_to].length -= 1;
	        balances[_rev_pay_money] = balances[_rev_pay_money].add(_cite.cite_value);
            balances[_rev_to] = balances[_rev_to].sub(_cite.cite_value);
      	    Transfer(_rev_to, _rev_pay_money, _cite.cite_value);
    	}
    }

    function _CentseCurrent() onlyOwner public {
	    if (rev_date[this] == 0) {
	        rev_date[this] = block.timestamp;
	    }
    }

    function addCite(address _rev_from, address _rev_to, uint16 _cite_value, uint64 _centseCurrent_effective, bool _cancelable, bool _burnsOnCancel) onlyOwner public {
	    this._addCite(_rev_from, _rev_to, _cite_value, _centseCurrent_effective, _cancelable, _burnsOnCancel);
    }
    
    function cancelCite(address _holder, uint256 _citeId) onlyOwner public {
	    this._cancelCite(_holder, _citeId);
    }
}

contract Review is Ownable {
    using SafeMath for uint;
    address public centseCurrent;
    uint public rev_date;
    address public rev_to;
    string public rev_title;
    bytes32 public rev_swarmHash;
    uint8 public outerTopic;
    address public editor;
    struct History {
	uint rev_date;
    	bytes32 rev_swarmHash; }
    History[] public history;
    struct PendingCite {
        address rev_to;
    	uint256 cite_value;
    	uint64 start;
    	bool cancelable;
    	bool burnsOnCancel; }
    PendingCite[] public pendingCites;
    event AddPendingCite(uint8 _length);

    function Review(address _author, address _centseCurrent, address _rev_to, string _rev_title, bytes32 _rev_swarmHash, uint8 _outerTopic, address _editor) {
        transferOwnership(_author);
        centseCurrent = _centseCurrent;
        rev_date = block.timestamp ;
        rev_to = _rev_to;
        rev_title = _rev_title ;
        rev_swarmHash = _rev_swarmHash ;
        outerTopic = _outerTopic;
        editor = _editor;
    }
    
    function addHistory(uint _rev_date, bytes32 _rev_swarmHash) public onlyOwner returns (uint) {
        return history.push(History(_rev_date, _rev_swarmHash));  
    }
    
    function addPendingCite(address[] _rev_to, uint16[] _cite_value, uint64[] _start, bool[] _cancelable, bool[] _burnsOnCancel) public onlyOwner {
        require (_rev_to.length == _cite_value.length && _rev_to.length == _start.length && _rev_to.length == _cancelable.length && _rev_to.length == _burnsOnCancel.length);
        for (uint8 i = 0 ; i < _rev_to.length ; i++) {
            pendingCites.push(PendingCite(_rev_to[i], _cite_value[i], _start[i], _cancelable[i], _burnsOnCancel[i]));
        }
        AddPendingCite(uint8(_rev_to.length));
    }
    
    function isPendingCite(address _rev_to, uint16 _cite_value, uint64 _start, bool _cancelable, bool _burnsOnCancel  ) public returns (bool) {
        require (msg.sender == owner || msg.sender == centseCurrent);
    	var pendingCiteslength = pendingCites.length;
    	for (uint8 i = 0 ; i < pendingCiteslength ; i++ ) {
            if (pendingCites[i].rev_to == _rev_to && pendingCites[i].cite_value == _cite_value
            	&& pendingCites[i].start >= _start 
                && _cancelable <= pendingCites[i].cancelable
                && pendingCites[i].burnsOnCancel <= _burnsOnCancel) {
        	delete pendingCites[i];
        	pendingCites[i] = pendingCites[pendingCiteslength.sub(1)];
        	pendingCites.length -= 1;
        	return true;
	    }
        }
    }

    function addCite(address _rev_from, address _rev_to, uint16 _cite_value, uint64 _centseCurrent_effective, bool _cancelable, bool _burnsOnCancel) onlyOwner public {
	    CentseCurrent _centseCurrent = CentseCurrent(centseCurrent);
	    _centseCurrent._addCite(_rev_from, _rev_to, _cite_value, _centseCurrent_effective, _cancelable, _burnsOnCancel);
    }
    
    function cancelCite(address _holder, uint256 _citeId) onlyOwner public {
	    CentseCurrent _centseCurrent = CentseCurrent(centseCurrent);
	    _centseCurrent._cancelCite(_holder, _citeId);
    }
}


contract Editor is Ownable {
    uint public ed_start;
    uint public ed_duration;
    uint8 public outerTopic;
    mapping (address => bool) public editors;
    
    function Editor(address _editor, uint _ed_start, uint  _ed_duration, uint8  _outerTopic) {
        transferOwnership(_editor);
        ed_start = _ed_start;
        ed_duration = _ed_duration;
        outerTopic = _outerTopic;  
    }

    function setEditor(address _editor, bool b) onlyOwner public  {
        editors[_editor] = b;
    }

    function confirmReview(address _rev_owner, address _rev_to, string _rev_title, bytes32 _rev_swarmHash, uint8 _outerTopic) public returns (bool) {
        return ((now <= (ed_start + ed_duration)) && _outerTopic == outerTopic);
    }

    function confirmEditor (address _rev, address _editor, address _rev_to) public returns  (bool) {
        return (editors[_editor]);
    }
}
