# SubtitleIt
# Webvtt
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

  def parse_webvtt
    @frmted = fix_vtt_empty_lines_gpt(@raw)
    @frmted.split(endl * 2).inject([]) do |final, line|
      line = line.split(endl)
      line.delete_at(0)
      unless line[0].nil?
        txtline = line[0].gsub(": ", ":")
        #  @logger.debug("3. parse_srt txtline:#{txtline}")
        time_on, time_off = txtline.split("-->").map(&:strip)
        line.delete_at(0)

        text = line.join("|")
        time_on, time_off = line[0].split("-->").map(&:strip)
        line.delete_at(0)
        text = line.join("|")
        final << SubtitleIt::Subline.new(time_on, time_off, text)
      end
    end
  end

  def to_webvtt
    out = []
    @lines.each_with_index do |l, i|
      unless l.blank?
        out << "#{i + 1}"
        #out << '%s --> %s' % [l.time_on.to_s(','), l.time_off.to_s(',')]
        out << "%s --> %s" % [l.time_on.to_s, l.time_off.to_s]
        out << (l.text ? l.text.gsub("|", endl) : " ") + endl
      end
    end
    srt = out.join(endl)

    # convert timestamps and save the file
    srt.gsub!(/([0-9]{2}:[0-9]{2}:[0-9]{2})([,])([0-9]{3})/, '\1.\3')
    # normalize new line character
    srt.gsub!("\r\n", "\n")

    srt = "WEBVTT\n\n#{srt}".strip
    return srt
  end

  def fix_vtt_empty_lines_gpt(content)
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
