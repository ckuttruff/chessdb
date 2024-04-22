module AppHelper

  def present?(obj)
    !obj.nil? && !obj.empty?
  end

  def link(url, description = nil)
    description ||= url
    "<a href='#{url}'>#{description}</a>"
  end

  # date_str eg: 20200719-03:20:02
  def format_date(date_str)
    DateTime.parse(date_str).
      strftime("%m/%d/%Y")
  end

  def pgn_text(game)
    moves = game['Moves']
    excluded_keys = %w(Moves FENs)
    text = game.filter{ |k,v| !excluded_keys.include?(k) }.map do |key, value|
      %Q{[#{key} "#{value}"]\n}
    end
    text << "\n#{moves}"
  end

end
