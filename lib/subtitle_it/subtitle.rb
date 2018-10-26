# encoding: utf-8
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
      @logger = Logging.logger("log/srt_logger.log")
      @logger.level = :debug
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
        #@logger = Logging.logger(STDOUT)
   
      end
      @filname=args[:filename]
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
   # def fix_marshal
   #     singleton_methods.each { |m| singleton_class.send(:remove_method, m) }
   #     singleton_class.class_eval do
   #       instance_variables.each { |v| remove_instance_variable v }
   #     end
   #   end
    
    def marshal_dump(*args)
        # singleton_methods.each { |m| singleton_class.send(:remove_method, m) }
        #  singleton_class.class_eval do
        #    instance_variables.each { |v| remove_instance_variable v }
        #  end
       saved_logger = @logger
       @logger = nil
       #
       # Save the marshalling method in an alias and then delete it so
       # there are no recursion worries.
       #
       self.class.send(:alias_method, :marshal_dump_foo, :marshal_dump)
       self.class.send(:remove_method, :marshal_dump)
       #
       # Now we should get a *real* marshalling of us and all of our bits,
       # friends, and relations.
       #
       marshalled = Marshal.dump(self)
       @logger = saved_logger || create_logger
       #
       # Put the original #marshal_dump (that's us!) back so we are as
       # we were before.
       #
       self.class.send(:alias_method, :marshal_dump, :marshal_dump_foo)
       self.class.send(:remove_method, :marshal_dump_foo)
       #
       # Now that we're ourselves (ourself?) again, *now* return the
       # result of dumping me/us.
       #
       return marshalled
     end
     
     def marshal_load(map_p)
        #
        # If we get a string, it's marshalled data.  Otherwise it's something
        # that Marshal#load has already frobbed.  Load it it we have to.
        #
        map = map_p.kind_of?(String) ? Marshal.load(map_p) : map_p
        #
        # For each instance variable in the newly-created Foo
        # object, copy it into ourself.
        #
        map.instance_variables.each do |ivar|
          self.instance_variable_set(ivar.to_sym,
                                     map.instance_variable_get(ivar.to_sym))
        end
        #
        # Make sure we point to ourself as the parent of this branch of
        # the Foo family.
        #
        @parent = self
        #
        # Make sure that all the restored children point to us, as well, rather
        # than the restored Foo object.
        #
        #@children.each { |o| o.parent = self }
        create_logger
        return self
      end

    private

    # Force subtitles to be UTF-8
    def encode_dump(dump)
      dump = dump.read unless dump.kind_of?(String)

      enc = CharlockHolmes::EncodingDetector.detect(dump)
      @logger.debug("\n...........\encode_dump #{enc}")
    
    #  if enc[:encoding] != 'UTF-8'
#        puts "Converting `#{enc[:encoding]}` to `UTF-8`"
        dump = CharlockHolmes::Converter.convert dump, enc[:encoding], 'UTF-8'
  #    end
      dump
    end

    def parse_dump(dump, format)
      @logger.debug("\n...........\nParsing #{@filename}")
      fail unless SUB_EXTS.include?(format)
      content = encode_dump(dump)
      
      @raw=fix_empty_lines(content)
    #  @raw=content
      @format = format
      parse_lines!
    end
    def fix_empty_lines(content)

       el=endline(content)
       

       #remove empty lines at start of file
       arcontent=content.split(el)       
       arcontent.each_with_index do |ar,i|
         if ar.match(/^[\xef\xbb\xbf\r\n\s]*$/u)
           arcontent.delete_at(i)
         else
           break
         end
       end
       
       content=arcontent.join(endline(content))
      
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
        arcontent=content.split(el)     
        arcontent.each_with_index do |line,i|
          
            pattern = (/\d{2}:\d{2}:\d{2},\d{3}?.*/)
            if line.match(pattern)
              #puts "matching at line #{i}, content: >#{line}<"
              #puts "|" + arcontent[i] + "|"

              (1..12).to_a.each do |ii|
                idx=ii+i
                if arcontent[idx] && arcontent[idx].blank?
              #  puts "text content for line #{i} is empty, replace by space  => >#{arcontent[i+1]}<"
                  arcontent.delete_at(idx)
                end
              end
            end
        end
        newcontent=arcontent.join(endline(content))
#        newcontent.gsub!(/^(\d+)\s*(\d{2}:\d{2}:\d{2},\d{3}?)/m, "\r\n\\1\r\n\\2")           
        newcontent.gsub!(/^(\d+)\s*(\d{2}:\d{2}:\d{2},\d{3}?)/mu, el + "\\1" + el + "\\2")  
        
                 
        newcontent.strip!
#        puts "|" + newcontent + "|"
        return newcontent
      
    end
    
    
    def parse_lines!
      self.lines = send :"parse_#{@format}"
    end
  end
end
