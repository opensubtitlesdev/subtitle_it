require 'logging'
# SubtitleIt
# SRT - Subrip format
#
# N
# 00:55:21,600 --> 00:55:27,197
# lt's not even 20 years. You've sold the
# casinos and made fortunes for all of us.
#
# Where N is the sub index number
#
module Formats
  include PlatformEndLine

  def endl
    endline(@raw)
  end

  def parse_srt
    @logger = Logging.logger("log/srt_logger.log")
    @logger.level = :debug
    # @logger.add_appenders \
    #     Logging.appenders.file('srt_logger.log')
    #@logger.debug("DEBUG parse_srt 00.  @raw:\n#{@raw}\n.......................")
   # puts "DEBUG parse_srt 00.  @raw:\n#{@raw}\n......................."
   # @raw=fix_srt_empty_lines_s(@raw)
    @frmted = fix_srt_empty_lines_gpt(@raw)
    @logger.debug("DEBUG parse_srt 01.  formatted:\n#{@raw}\n.......................\n#{@frmted }")
    @frmted.split(endl * 2).inject([]) do |final, line|


      @logger.debug("1. parse_srt line:#{line.inspect}")
      line = line.split(endl)
      line.delete_at(0)
      @logger.debug("2. parse_srt line[0]:#{line[0]}")
      unless line[0].nil?
        txtline=line[0].gsub(": ",":")
         @logger.debug("3. parse_srt txtline:#{txtline}")
        time_on, time_off = txtline.split('-->').map(&:strip)
        line.delete_at(0)

        text = line.join('|')
        # if text.nil?
         #puts("2. parse_srt time_on:#{time_on} time_off:#{time_off} text:#{text}")

        # end
        final << SubtitleIt::Subline.new(time_on, time_off, text) unless final.nil?
      else
        @logger.debug("SHIT IS HERE parse_srt line:#{line.inspect}")
      end
    end
  end

  def to_srt
    @logger = Logging.logger("log/srt_logger.log")

    out = []
    @lines.each_with_index do |l, i|
     # @logger.debug("to_srt >>> to_srt time on:#{l.time_on} time off:#{l.time_off} i:#{i}")
      unless l.time_on.nil? && l.time_off.nil?
        out << "#{i + 1}"
        out << '%s --> %s' % [l.time_on.to_s(','), l.time_off.to_s(',')]
        # out << '%s --> %s' % [l.time_on.to_s, l.time_off.to_s]
        #out << '%s --> %s' % [l.time_on.to_s, l.time_off.to_s]
        out << (l.text ? l.text.gsub('|', endl) : ' ') + endl
      end
    end
    out.join(endl)
  end

  def fix_srt_empty_lines_gpt(content)
   # puts "\n............\norig:\n"+content
    lines = content.split("\n")

  # Iterate through the lines and replace lines with only whitespace after a number and before a timestamp with "...\n"
  # and remove lines with only whitespace after a timestamp and before a subtitle
  processed_lines = lines.each_with_index.map do |line, index|
    if index > 0 && index < lines.length - 1 && lines[index - 1].include?(" --> ") && line =~ /^\s*$/
      if lines[index + 1].match(/^\d+$/)
        "...\n"
      elsif lines[index + 1] !~ /^\s*$/ && lines[index + 1] !~ / --> /
        nil
      else
        line
      end
    else
      line
    end
  end.compact
    processed_s = processed_lines.join("\n")
  #  puts "\n............\nprocessed:\n"+ processed_s 
    processed_s
    
  end



  

  def fix_srt_empty_lines_s(content)
   # content.gsub!(/(.*?\d\d:\d\d:\d\d[,\.]\d{3}\s+--\>\s+\d\d:\d\d:\d\d[,\.]\d{3})\s*(.*)/, "\\1\r\n\\2")
    #content.gsub!(/(.*?\d\d:\d\d:\d\d[,\.]\d{3}\s+--\>\s+\d\d:\d\d:\d\d[,\.]\d{3}\s*.*? *\r?\n *\r?\n)(?:\s*)(.*)/, "\\1\\2").strip!
    el=endline(content)
    arcontent=content.split(el)
    #arcontent.reverse!
    #arcontent.each_with_index do |ar,i|
    #  if ar.blank? || ar=="\n"
    #    arcontent.delete_at(i)
    #  else
    #    break
    #  end
    # end
    # arcontent.reverse!
    #


    arcontent.each_with_index do |line,i|
      pattern = (/\d{2}:\d{2}:\d{2},\d{3}?.*/)
      if line.match(pattern)
        #  puts "matching at line #{i}, content: >#{line}<"
        if arcontent[i+1] && arcontent[i+1].blank?
          #  puts "text content for line #{i} is empty, replace by space  => >#{arcontent[i+1]}<"
          # arcontent[i+1]=":..:"
          arcontent[i+1]="   "
        end
      end
    end
    newcontent=arcontent.join(endline(content))
    return newcontent
  end

  def fix_srt_empty_lines(content)
#   content.gsub!(/(.*?\d\d:\d\d:\d\d[,\.]\d{3}\s+--\>\s+\d\d:\d\d:\d\d[,\.]\d{3}\s[\r\n]*.*?[\r\n]{2})(?:[\r\n]*\s*)+(.*)/, '\\1\\2')
#   content=content.gsub(/(.*?\d\d:\d\d:\d\d[,\.]\d{3}\s+--\>\s+\d\d:\d\d:\d\d[,\.]\d{3}\s[\r\n]*.*?[\r\n]{2})(?:[\r\n]*\s*)+(.*)/, '\\1\\2').strip!



    #remove newlines after timestamp
    content.gsub!(/(.*?\d\d:\d\d:\d\d[,\.]\d{3}\s+--\>\s+\d\d:\d\d:\d\d[,\.]\d{3})\s*(.*)/, "\\1\r\n\\2")

    #remove newlines in text
    content.gsub!(/(.*?\d\d:\d\d:\d\d[,\.]\d{3}\s+--\>\s+\d\d:\d\d:\d\d[,\.]\d{3}\s*.*? *\r?\n *\r?\n)(?:\s*)(.*)/, "\\1\\2").strip!


    el=endline(content)
    arcontent=content.split(el)
    #arcontent.reverse!
    #arcontent.each_with_index do |ar,i|
    #  if ar.blank? || ar=="\n"
    #    arcontent.delete_at(i)
    #  else
    #    break
    #  end
    # end
    # arcontent.reverse!
    #


    arcontent.each_with_index do |line,i|
      pattern = (/\d{2}:\d{2}:\d{2},\d{3}?.*/)
      if line.match(pattern)
        #  puts "matching at line #{i}, content: >#{line}<"
        if arcontent[i+1] && arcontent[i+1].blank?
          #  puts "text content for line #{i} is empty, replace by space  => >#{arcontent[i+1]}<"
          # arcontent[i+1]=":..:"
          arcontent[i+1]="   "
        end
      end
    end
    newcontent=arcontent.join(endline(content))
    return newcontent
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
