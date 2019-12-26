pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract ticketingSystem{
    using SafeMath for uint;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    //mapping(address => artist) public _artistProfile;


    //structure of artist

    struct artist{
        address owner;
        uint id;
        string name;
        uint artistCategory;
        uint totalTickets;
    }

    uint numberOfArtists;
    artist[] listArtists;

    //structure of venue

    struct venue{
        address owner;
        uint id;
        string name;
        uint capacity;
        uint comission;
    }

    uint numberOfVenues;
    venue[] listVenues;

    //structure of concert

    struct concert{
        uint id;
        uint artistId;
        uint venueId;
        uint date;
        uint ticketPrice;
        bool validatedByArtist;
        bool validatedByVenue;
        uint totalSoldTicket;
        uint totalMoneyCollected;
    }

    uint numberOfConcerts;
    concert[] listConcerts;

    //structure of ticketingSystem

    struct ticket{
        address owner;
        uint id;
        uint concertId;
        bool isAvailable;
    }

    uint numberOfTickets;
    ticket[] listTickets;

    /**
     * Constructor
     */

    constructor () public {
       numberOfArtists = 1;
       numberOfVenues = 1;
       numberOfConcerts = 1;
       numberOfTickets = 1;
    }

    /** 
    * Functions artist
    */

    function createArtist(string memory _name, uint _artistCategory) public {
        artist memory _artist = artist(msg.sender,numberOfArtists, _name, _artistCategory, 0);
        //_artistProfile[msg.sender] = _artist;

        listArtists.push(_artist);
        numberOfArtists++;
    }

    function artistsRegister(uint _id) public view returns (address owner, string memory name, uint artistCategory, uint totalTicket){
        artist memory _artist = listArtists[_id -1];
        return (_artist.owner, _artist.name, _artist.artistCategory, _artist.totalTickets);
    }

    function modifyArtist(uint _id, string memory _name, uint _artistCategory, address payable _newOwner) public {
    
        require(isArtistOwner(msg.sender, _id),
            "Ticketing: wrong account owner"
        );

        artist memory oldArtist = listArtists[_id -1];
        artist memory newArtist = artist(_newOwner,oldArtist.id, _name, _artistCategory, oldArtist.totalTickets);
        
        listArtists[_id -1] = newArtist;
    }

    function isArtistOwner(address account, uint idArtist) public view returns (bool) {
        if(listArtists[idArtist -1].owner == account)
            return true;
        else
            return false;
    }

    /** 
    * Functions venue
    */

    function createVenue(string memory _name, uint _capacity, uint _standardComission) public {
        venue memory _venue = venue(msg.sender,numberOfVenues, _name, _capacity, _standardComission);

        listVenues.push(_venue);
        numberOfVenues++;
    }

    function venuesRegister(uint _id) public view returns (address owner, string memory name, uint capacity, uint standardComission){
        venue memory _venue = listVenues[_id -1];
        return (_venue.owner, _venue.name, _venue.capacity, _venue.comission);
    }

    function modifyVenue(uint _id, string memory _name, uint _capacity, uint _standardComission, address payable _newOwner) public {
    
        require(isVenueOwner(msg.sender, _id),
            "Ticketing: wrong account owner"
        );

        venue memory oldVenue = listVenues[_id -1];
        venue memory newVenue = venue(_newOwner,oldVenue.id, _name, _capacity, _standardComission);
        
        listVenues[_id -1] = newVenue;
    }

    function isVenueOwner(address account, uint idVenue) public view returns (bool) {
        if(listVenues[idVenue -1].owner == account)
            return true;
        else
            return false;
    }

    /** 
    * Functions concerts
    */

    function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice) public {

        concert memory _concert;

        if(isArtistOwner(msg.sender, _artistId) == true)
            _concert = concert(numberOfConcerts, _artistId, _venueId, _concertDate, _ticketPrice, true, false, 0, 0);
        else if(isVenueOwner(msg.sender, _venueId) == true)
            _concert = concert(numberOfConcerts, _artistId, _venueId, _concertDate, _ticketPrice, false, true, 0, 0);
        else
            _concert = concert(numberOfConcerts, _artistId, _venueId, _concertDate, _ticketPrice, false, false, 0, 0);

        listConcerts.push(_concert);
        numberOfConcerts++;
    }

    function concertsRegister(uint _id) public view returns (uint artistId, uint concertDate, bool validatedByArtist, bool validatedByVenue, uint totalSoldTicket, uint totalMoneyCollected){
        concert memory _concert = listConcerts[_id -1];
        return (_concert.artistId, _concert.date, _concert.validatedByArtist, _concert.validatedByVenue, _concert.totalSoldTicket, _concert.totalMoneyCollected);
    }

    function validateConcert(uint _concertId) public {

        concert memory _concert = listConcerts[_concertId -1];

        require(isVenueOwner(msg.sender, _concert.venueId) || isArtistOwner(msg.sender, _concert.artistId),
            "Ticketing: wrong account owner"
        );

        concert memory newConcert;

        if(isVenueOwner(msg.sender, _concert.venueId))
            newConcert = concert(_concert.id, _concert.artistId, _concert.venueId, _concert.date, _concert.ticketPrice, _concert.validatedByArtist, true, _concert.totalSoldTicket, _concert.totalMoneyCollected);
        else
            newConcert = concert(_concert.id, _concert.artistId, _concert.venueId, _concert.date, _concert.ticketPrice, true, _concert.validatedByVenue, _concert.totalSoldTicket, _concert.totalMoneyCollected);
        
        listConcerts[_concertId -1] = newConcert;
    }

    function emitTicket(uint _concertId, address payable _ticketOwner) public {

        concert memory _concert = listConcerts[_concertId -1];

        require(isArtistOwner(msg.sender, _concert.artistId),
            "Ticketing: wrong artist account owner"
        );

        ticket memory _ticket = ticket(_ticketOwner, numberOfTickets, _concertId, true);

        listTickets.push(_ticket);
        numberOfTickets++;

        concert memory newConcert =  concert(_concert.id, _concert.artistId, _concert.venueId, _concert.date, _concert.ticketPrice, _concert.validatedByArtist, _concert.validatedByVenue, _concert.totalSoldTicket + 1, _concert.totalMoneyCollected);
        listConcerts[_concertId -1] = newConcert;
    }

    function ticketsRegister(uint _id) public view returns (address owner, uint concertId, bool isAvailable){
        ticket memory _ticket = listTickets[_id -1];
        return (_ticket.owner, _ticket.concertId, _ticket.isAvailable);
    }

    function useTicket(uint _id) public {

        uint actualTime = now;
        uint oneDay = 60*60*24;
        ticket memory _ticket = listTickets[_id -1];
        concert memory _concert = listConcerts[_ticket.concertId -1];

        require(isTicketOwner(msg.sender, _id) == true && _concert.validatedByVenue == true && actualTime >= _concert.date - oneDay,
            "Ticketing: wrong account owner or not validated or not good time"
        );

        ticket memory newTicket = ticket(address(0), _ticket.id, _ticket.concertId, false);
        listTickets[_id -1] = newTicket;
    }

    function isTicketOwner(address account, uint idTicket) public view returns (bool) {
        if(listTickets[idTicket -1].owner == account)
            return true;
        else
            return false;
    }

    /** 
    * Functions ERC20
    */
    
    function balanceOf(address _owner) public view returns (uint balance){
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success){
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining){
        return allowed[_owner][_spender];
    }

    /**
    * Events
    */

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}
