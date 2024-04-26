# coding: utf-8
require 'digest'
require 'elasticsearch'
require 'json'

class Search
  ENGINE_ELO = 3000
  INDEX_NAME = 'chess-db'
  RUBY_DATE_FORMAT   = "%Y.%m.%d"
  MAX_SEARCH_RESULTS = 100

  attr_reader :client
  def initialize()
    @client = Elasticsearch::Client.new(
      host: "http://localhost:9200",
    )
    @client.transport.reload_connections!
    create_index
  end

  def index!
    to_index = []
    counter = 1
    game = {}

    Dir["data/**/*.pgn"].each do |file|
      puts file
      IO.foreach(file) do |line|
        begin
          next if line =~ /^\s*$/
        rescue
          puts line
          next
        end

        new_pgn = line.start_with?('[Event "')

        if(new_pgn && !game.empty?)
          if(engine?(game['WhiteElo']) || engine?(game['BlackElo']))
            game = {}
            next
          end
          pgn_extract_cmd = "pgn-extract --keepbroken -C --quiet -Wepd 2> /dev/null"
          format_cmd = "cut -d' ' -f1 | sed '/^$/d'"
          game['FENs'] = `echo "#{game['Moves']}" | #{pgn_extract_cmd} | #{format_cmd}`.strip

          to_index << { index: { _index: INDEX_NAME, _id: get_unique_id(game), data: game }}
          game = {}
          counter += 1

          if(!to_index.empty? && (counter % 10_000 == 0))
            @client.bulk(body: to_index)
            to_index = []
          end
        end

        if line.start_with?("[")
          set_metadata(game, line)
        else
          game['Moves'] ||= ''
          game['Moves'] += " #{line.strip}"
        end
      end
      @client.bulk(body: to_index) if !to_index.empty?
      to_index = []
    end
  end

  def search(query, fen, start_date = nil, end_date = nil)
    start_date ||= Date.new(1, 1, 1)
    end_date   ||= Date.today
    q =  %Q{Date:["#{date_str(start_date)}" TO "#{date_str(end_date)}"]}
    q += %Q{ AND FENs:"#{fen}"} unless fen.empty?
    q += %Q{ AND #{query}} unless query.empty?

    @client.search(index: INDEX_NAME, q: q, sort: 'Date:desc',
                   size: MAX_SEARCH_RESULTS)['hits']['hits'].
      map { |res| res['_source'] }
  end

  private

  def get_unique_id(game)
    str = game.values_at('Date', 'White', 'Black', 'Result', 'Moves').join
    Digest::SHA2.hexdigest(str)
  end

  def create_index
    index_exists = @client.indices.exists?(index: INDEX_NAME)
    @client.indices.create(
      { index: INDEX_NAME,
        body: { mappings: {
                  properties: {
                    Event:       { type: 'text' },
                    Site:        { type: 'text' },
                    # see java java time DateTimeFormatter docs
                    Date:        { type: 'date',
                                   format: 'uuuu.MM.dd' },
                    EventDate:   { type: 'date',
                                   format: 'uuuu.MM.dd' },
                    Round:       { type: 'text' },
                    Result:      { type: 'text' },
                    White:       { type: 'text' },
                    Black:       { type: 'text' },
                    WhiteElo:    { type: 'unsigned_long' },
                    BlackElo:    { type: 'unsigned_long' },
                    WhiteTitle:  { type: 'text' },
                    BlackTitle:  { type: 'text' },
                    WhiteFideId: { type: 'unsigned_long' },
                    BlackFideId: { type: 'unsigned_long' },
                    ECO:         { type: 'text' },
                    Opening:     { type: 'text' },
                    Variation:   { type: 'text' },
                    Moves:       { type: 'text' },
                    FENs:        { type: 'text' }}}}}) unless index_exists
  end

  def engine?(elo_str)
    elo_str && !elo_str.empty? && elo_str.to_i > ENGINE_ELO
  end

  def date_str(date)
    date.strftime(RUBY_DATE_FORMAT)
  end

  def set_metadata(game, line)
    metadata_regex = /^\[([\w]+) "(.+)"\]$/
    begin
      match = metadata_regex.match(line)
    rescue
      puts '------------------------------------'
      puts "parse error: #{game.inspect}"
      return
    end
    if(match)
      field, value = match.captures
      if %w(Date EventDate).include?(field)
        begin
          value = date_str(Date.parse(value))
        rescue Date::Error
          value = nil
        end
      end
      game[field] = value
    end
  end
end
