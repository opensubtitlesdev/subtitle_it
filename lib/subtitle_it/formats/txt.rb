require 'logging'
# SubtitleIt
# TXRT - Txt only format !! unusable as subtitle file !!
#
# 
# 
# lt's not even 20 years. You've sold the
# casinos and made fortunes for all of us.
#
#
module Formats
  include PlatformEndLine

  def endl
    endline(@raw)
  end

  def parse_txt


    @raw.split(endl * 2).inject([]) do |final, line|


      line = line.split(endl)
      line.delete_at(0)
      #  @logger.debug("2. parse_srt line:#{line.inspect}")      
      unless line[0].nil?
        time_on, time_off = line[0].split('-->').map(&:strip)
        line.delete_at(0)
        #   @logger.debug("3. parse_srt line:#{line.inspect}")              
        text = line.join('|')
        # if text.nil?        

        # end
        final << SubtitleIt::Subline.new(time_on, time_off, text) unless final.nil?
      else
        # @logger.debug("SHIT IS HERE parse_srt line:#{line.inspect}")      
      end
    end
  end

  def to_txt
    out = []
    @lines.each_with_index do |l, i|
      #out << '%s --> %s' % [l.time_on.to_s, l.time_off.to_s]
      out << (l.text ? l.text.gsub('|', endl) : ' ') + endl
    end
    out.join(endl)
  end

end

# looks like subrip accepts some styling:
#     sdict.add(new StyledFormat(ITALIC, "i", true));
#     sdict.add(new StyledFormat(ITALIC, "/i", false));
#     sdict.add(new StyledFormat(BOLD, "b", true));
#     sdict.add(new StyledFormat(BOLD, "/b", false));
#     sdict.add(new StyledFormat(UNDERLINE, "u", true));
#     sdict.add(new StyledFormat(UNDERLINE, "/u", false));
#     sdict.add(new StyledFormat(STRIKETHROUGH, "s", true));
#     sdict.add(new StyledFormat(STRIKETHROUGH, "/s", false));
