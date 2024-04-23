## Chess DB

This project is a simple Ruby / Sinatra application to leverage Elasticsearch, various chess game databases (Caissabase / This Week in Chess, etc), and nice PGN viewers / editors to offer powerful search of millions of the top chess games throughout history.

### Features
* Enter a board position to search openings / specific positions
* Filter by date range, player, event, and any other PGN metadata
* Fast! (Even on modest hardware, sophisticated searches can be run very quickly)
* Beautiful PGN viewer / editor utilizing board tools from Lichess and @mliebelt

### Motivation
* We need more free, open-source tools around searching for chess games
* Chessbase needs to die
  - limited functionality, expensive, windows-only desktop app, crusty AF
* SCID is an amazing tool, but the interface is outdated / unintuitive and applying filters is limited
* Much appreciation to sites like chessgames.com and others, but the design is stale and search is limited

### Future plans
* Production deploy
  - ensuring we have enough compute resources for demand
* Better search interface
  - allow one to enter FEN string or edit board more easily
* Pagination for search results
* Adding other databases (keeping up to date with TWIC and other key sources)
* Database exports
  - As an example, if you have a filter for all Smith Mora gambit games where Magnus Carlsen played White and won, have ability to export a PGN of that specific search
