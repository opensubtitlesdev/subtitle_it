# SubtitleIt
# Time class
module SubtitleIt
  # A kinda of Time
  class Subtime
    attr_accessor :hrs, :min, :sec, :ms

    def initialize(data)
      @logger = Logging.logger("log/srt_logger.log")
      @use_ms_str = false
      fail "failed initialize subtime" if data.nil?
      parse_data(data)
    end

    # parses string like '00:00:00,000' or single number as ms.
    def parse_data(data)

      case data
      when Numeric
        @logger.debug("parse_data data: #{data} Numeric")
        @sec, @ms  = data.divmod(1000)
        @min, @sec = @sec.divmod(60)
        @hrs, @min = @min.divmod(60)

        @use_ms_str = false
      when String
         @logger.debug("parse_data data: #{data} String")
        time, float = data.split(/\.|\,/)
        time = time.split(/:/).map(&:to_i)
        if float
          float_i = float.to_i
          if float_i < 100 && float.length == 3
            @use_ms_str = true
          end
          
          @ms =  (('0.%d' % float.to_i).to_f * 1000).to_i 
          @ms_str = float
        end
        
     #   @ms_str = float if float
        
    #    @logger.debug("parse_data float: #{float}  @ms:#{ @ms}")
        @sec, @min, @hrs = time.reverse
      else fail 'Format unknown.'
      end
      # FIXME: dunno what to do about this.. nil = problems with to_i
      @hrs ||= 0; @min ||= 0; @sec ||= 0;  @ms ||= 0
    end

    # to_s(separator) => to_s(",") => 00:00:00,000
    def to_s(sep = '.')
    #  @logger.debug("output line: with hrs:#{@hrs} min:#{@min} sec:#{@sec} ms:#{@ms} ms_str:#{@ms_str}")
      
      if  @use_ms_str
      #  @logger.debug(" use ms str !")
        "%02d:%02d:%02d#{sep}#{@ms_str}" % [@hrs, @min, @sec]
      else  
        "%02d:%02d:%02d#{sep}%03d" % [@hrs, @min, @sec,  @ms]
      end

   
      
    end

    # return time as a total in ms
    def to_i
      (@hrs * 3600 + @min * 60 + @sec) * 1000 + @ms
    end

    def +(other)
      Subtime.new(to_i + other.to_i)
    end

    def -(other)
      Subtime.new(to_i - other.to_i)
    end

    def <=>(other)
      to_i <=> other.to_i
    end
    include Comparable
  end
end
