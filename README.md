"# TD_Ticketing" 

To create a ticketing contract, I use the functions of ERC20 contracts.

To create a artist profile, I created a structure "artist" with the necessary variables. And I created a list (array) of artist with the owner accounts (for the mapping). I created the functions who gives the information of one artist, and a function which modify an artist, it create a new artist with the new inforations and replace it in the list. In addition, I created a function 'IsOwner' which is call to verify if the message sender is the artist.

It's exactly the same for venue.

To create the concert, it's the same, but there is no owner of a concert. I had to create other function : validate concert, and check if the message sender is the venue or the artist of the concert.

To emit ticket, I had to check if the message sender is an artist, and increment the variable "totalTicketSold"

To use ticket, it was important to check three things : ticket can be used 24h before the concert, the message sender have to have ticket and the concert was validated by the venue. After the ticket isn't available and the owner of the ticket become "adress(0)".


To run test, I had to create a migrations file, and run "truffle test" which run all the tests. And all passing.
