require 'logging'

# SubtitleIt
# Holds a subtitle`s line.
module SubtitleIt
  class Subline
    attr_accessor :time_on, :time_off, :text
    # time_on/off may be:
    # HH:MM:SS,MMM
    # MM:SS
    # S
    # text lines should be separated by |
    def initialize(time_on, time_off, text)
#      @logger = Logging.logger(STDOUT)
      @logger = Logging.logger("log/srt_logger.log")
      
      @logger.level = :debug
     
      unless time_on.nil? || time_off.nil?
        @time_on, @time_off = filter(time_on, time_off)
        # ugly FIXME: when pseudo uses time => 3 or TT format
        # need to add seconds on time_off to time_on
        @time_off += @time_on if @time_off < @time_on
        @text = text
        #@logger.debug("Subline with time_on:#{time_on} - time_off:#{time_off} text: #{text}")
      else
        @logger.debug("Error Subline with time_on:#{time_on} - time_off:#{time_off} text: #{text}")
        @text=nil
      end
    end

    def filter(*args)
      args.map do |arg|
        Subtime.new(arg)
      end
    end
  end
end
