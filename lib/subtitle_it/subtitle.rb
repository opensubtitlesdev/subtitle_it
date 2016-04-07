require 'subtitle_it/formats/srt'
require 'subtitle_it/formats/sub'
require 'subtitle_it/formats/yml'
require 'subtitle_it/formats/rsb'
require 'subtitle_it/formats/xml'
require 'subtitle_it/formats/txt'
require 'subtitle_it/formats/mpl'
require 'subtitle_it/formats/webvtt'
require 'subtitle_it/formats/dfxp'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'logging'

# http://en.wikipedia.org/wiki/List_of_ISO_639-2_codes
# http://www.opensubtitles.org/addons/export_languages.php

module SubtitleIt
  MOVIE_EXTS = %w(3g2 3gp 3gp2 3gpp 60d ajp asf asx avchd avi bik bix box cam dat divx dmf dv dvr-ms evo flc fli flic flv flx gvi gvp h264 m1v m2p m2ts m2v m4e m4v mjp mjpeg mjpg mkv moov mov movhd movie movx mp4 mpe mpeg mpg mpv mpv2 mxf nsv nut ogg ogm omf ps qt ram rm rmvb swf ts vfw vid video viv vivo vob vro wm wmv wmx wrap wvx wx x264 xvid)
  SUB_EXTS = %w(srt sub smi txt ssa ass mpl xml yml rsb webvtt dfxp txt)



  class Subtitle
    include Comparable
    include Formats
    attr_reader :id, :raw, :format, :lines, :style, :info, :filename, :rating, :language, :user, :release_name,
                :osdb_id, :download_count, :download_url, :original_filename
    attr_writer :style, :lines, :fps

    def initialize(args = {})
      # Looks like opensubtitle is the only provider around..
      # If a second one comes need big refactor...
      if @info = args[:info]
        # @osdb_info         = info
        @osdb_id           = @info['IDSubtitleFile'].to_s
        @original_filename = @info['SubFileName'].to_s
        @format            = @info['SubFormat'].to_s
        @user              = @info['UserNickName'].to_s
        @language          = @info['LanguageName'].to_s
        @release_name      = @info['MovieReleaseName'].to_s
        @download_count    = @info['SubDownloadsCnt'].to_i
        @rating            = @info['SubRating'].to_f
        @uploaded_at       = @info['SubAddDate'].to_s # TODO: convert to time object?
        @download_url      = @info['SubDownloadLink'].to_s
        @logger = Logging.logger(STDOUT)
        @logger.level = :debug
      end
      @fps = args[:fps] || 23.976
      return unless dump = args[:dump]
      parse_dump(args[:dump], args[:format])
    end

    def data=(data)
      @raw = data
    end

    def <=>(other)
      rating <=> other.rating
    end

    private

    # Force subtitles to be UTF-8
    def encode_dump(dump)
      dump = dump.read unless dump.kind_of?(String)

      enc = CharlockHolmes::EncodingDetector.detect(dump)
      if enc[:encoding] != 'UTF-8'
#        puts "Converting `#{enc[:encoding]}` to `UTF-8`"
        dump = CharlockHolmes::Converter.convert dump, enc[:encoding], 'UTF-8'
      end
      dump
    end

    def parse_dump(dump, format)
      fail unless SUB_EXTS.include?(format)
      content = encode_dump(dump)
      
    #  @raw=fix_empty_lines(content)
      @raw=content
      @format = format
      parse_lines!
    end
    def fix_empty_lines(content)

       el=endline(content)
       

       content.strip!
                   
       arcontent=content.split(el)
      
       # remove empty lines at bottom of file
     #  arcontent.reverse!
     #  arcontent.each_with_index do |ar,i|
     #    if ar.blank? || ar=="\n"
     #      arcontent.delete_at(i)
     #    else
     #      break
     #    end
     #   end
     #   arcontent.reverse!                   
        
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
        
       # newcontent.gsub!(/[\r\n][\r\n][\r\n]+/, "\r\n\r\n")   
#        puts newcontent

        
        return newcontent
      
    end
    
    
    def parse_lines!
      self.lines = send :"parse_#{@format}"
    end
  end
end
