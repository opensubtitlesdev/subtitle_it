require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Formats, '.srt' do
  include SubFixtures
  describe 'In' do
    before(:each) do
      @srt = Subtitle.new(dump: srt_fixture, format: 'srt')
    end
  
    it 'should parse the sub to an array' do
      expect(@srt.lines).to be_instance_of(Array)
    end
  
    #it 'should have N lines' do
    #  expect(@srt.lines.length).to eq(543)
    #end
  
    it 'should parse time of' do
      expect(@srt.lines[0].time_on.to_s).to eql('00:01:43.680')
    end
  
    it 'should parse time of' do
      expect(@srt.lines[0].time_off.to_s).to eql('00:01:45.557')
    end
  
   # it 'should parse text' do
   #   expect(@srt.lines[0].text).to eql('My dear children,')
   # end
  end
#  describe "Bugged srt management" do
#    before(:each) do
#      @srt = Subtitle.new(dump: bugged_srt_fixture, format: 'srt')
#      @raw_content=bugged_srt_fixture.read.split("\n")
#     
#    end
#   it 'should parse the sub to an array' do
#     expect(@srt.lines).to be_instance_of(Array)
#   end
#   it 'should have N lines' do
#      expect(@srt.lines.length).to eq(40)
#    end
#   it 'should replace empty lines with spaces' do
#     expect(@srt.lines[5].text).to eq("   ")
#   end
#   it 'should have the right amount of lines in raw content' do
#     expect(@raw_content.size).to eq(181)
#   end
# 
#    
#  end
  describe 'bugged empty lines' do
     before(:each) do
       @empty_lines=Subtitle.new(dump: bugged_empty_lines, format: 'srt')
      # @raw_content=bugged_empty_lines.read.split("\n")
      end
      it 'should parse the file with empty lines' do
#                puts "some ugly debug:#{@empty_lines.lines.inspect}"
         expect(@empty_lines.lines).to be_instance_of(Array)
       end
       it 'should fix problem with empty lines at the end of a file' do
          expect(@empty_lines.lines.length).to eq(10)
       end
  end
  describe 'polish bug' do
    before(:each) do
      @st_polish_bug=Subtitle.new(dump: polish_bug_short, format: 'srt')
     # @raw_content=bugged_empty_lines.read.split("\n")
     puts  @st_polish_bug.to_srt
     end
     it 'should parse the file with empty lines in polish file' do
#                puts "some ugly debug:#{@empty_lines.lines.inspect}"
        expect(@st_polish_bug.lines).to be_instance_of(Array)
      end
      it 'should fix problem with empty lines at the end of a file' do
         expect(@st_polish_bug.lines.length).to eq(196)
      end
 end
   describe 'not sure if problem' do
       before(:each) do
         @not_sure_if_problem=Subtitle.new(dump: not_sure_if_problem, format: 'srt')
        # @raw_content=bugged_empty_lines.read.split("\n")
        end
        it 'should parse the file not sure' do
  #                puts "some ugly debug:#{@empty_lines.lines.inspect}"
           expect(@not_sure_if_problem.lines).to be_instance_of(Array)
         end
         it 'should fix problem with file not sure' do
            expect(@not_sure_if_problem.lines.length).to eq(778)
         end
    end
    describe 'doubled timestamp' do
      before(:each) do
        @double_timestamp=Subtitle.new(dump: double_timestamp, format: 'srt')
        @raw_content=double_timestamp.read.split("\n")
       end
       it 'should parse the file ndouble_timestamp' do
                 puts "some ugly debug:#{@raw_content.inspect}"
                 puts "some more :#{@double_timestamp.to_srt}"
          expect(@double_timestamp.lines).to be_instance_of(Array)
        end
    #    it 'should fix problem with file double_timestamp' do
    #       expect(@double_timestamp.lines.length).to eq(2)
    #    end
   end
   
    
     describe 'should parse' do
         before(:each) do
           @should_parse=Subtitle.new(dump: should_parse, format: 'srt')
          # @raw_content=bugged_empty_lines.read.split("\n")
          end
          it 'should parse the should_parse' do
    #                puts "some ugly debug:#{@empty_lines.lines.inspect}"
             expect(@should_parse.lines).to be_instance_of(Array)
           end
          #it 'should fix problem with should_parse' do
          #   expect(@should_parse.lines.length).to eq(778)
          #end
      end
       describe 'should parse 2019' do
           before(:each) do
             @should_parse=Subtitle.new(dump: should_parse_2019, format: 'srt')
            # @raw_content=bugged_empty_lines.read.split("\n")
            end
            it 'should parse the should_parse' do
              
                                  # puts "some ugly debug:#{@should_parse.lines.inspect}"
                     puts "some ugly debug:#{@should_parse.lines.inspect}"
                     puts @should_parse.to_srt
               expect(@should_parse.lines).to be_instance_of(Array)
             end
            #it 'should fix problem with should_parse' do
            #   expect(@should_parse.lines.length).to eq(778)
            #end
        end
      
      
     describe 'parse arabic problem' do
         before(:each) do
           @parse_arabic=Subtitle.new(dump: parse_arabic, format: 'srt')
          # @raw_content=bugged_empty_lines.read.split("\n")
          end
          it 'should parse the parse_arabic' do
    #                puts "some ugly debug:#{@empty_lines.lines.inspect}"
             expect(@parse_arabic.lines).to be_instance_of(Array)
           end
           it 'should fix problem with parse_arabic' do
             puts @parse_arabic.to_webvtt
              expect(@parse_arabic.lines.length).to eq(27)
           end
      end
    
  

    describe 'problem many empty lines' do
        before(:each) do
          @problem_many_empty_lines=Subtitle.new(dump: problem_many_empty_lines, format: 'srt')
         # @raw_content=bugged_empty_lines.read.split("\n")
         end
         it 'should parse the file with many empty lines' do
   #                puts "some ugly debug:#{@empty_lines.lines.inspect}"
            expect(@problem_many_empty_lines.lines).to be_instance_of(Array)
          end
          it 'should fix problem with many empty lines' do
             expect(@problem_many_empty_lines.lines.length).to eq(8)
          end
     end
  
      describe 'problem srt tabs' do
          before(:each) do
            @srt_tabs_fixture=Subtitle.new(dump: srt_tabs_fixture, format: 'srt')
           # @raw_content=bugged_empty_lines.read.split("\n")
           end
           it 'should parse the file with weird tabulations lines' do
     #                puts "some ugly debug:#{@empty_lines.lines.inspect}"
              expect(@srt_tabs_fixture.lines).to be_instance_of(Array)
            end
            it 'should fix problem withweird tabulations ' do
               expect(@srt_tabs_fixture.lines.length).to eq(994)

               puts @srt_tabs_fixture.to_srt
            end
            
            
       end
       
       describe 'bug timestamps' do
         before(:each) do
           @bug_timestamps=Subtitle.new(dump: bug_timestamps, format: 'srt')        
          end
           it 'should parse the file and have proper timestamps' do
     #                puts "some ugly debug:#{@empty_lines.lines.inspect}"
              expect(@bug_timestamps.lines).to be_instance_of(Array)
              line=@bug_timestamps.lines[0]
              #puts "time on: #{line.time_on.to_s(',')}"
              #puts "time off: #{line.time_off.to_s(',')}"
              #puts "text: #{line.text}"
              expect(line.time_on.to_s(',')).to eq("00:02:35,046")
              
              #puts @bug_timestamps.to_srt
              
            end
       end
  
  
  
  
  
       describe 'problem missing first ts' do
           before(:each) do
             @missing_first_stamp=Subtitle.new(dump: missing_first_stamp, format: 'srt')
            # @raw_content=bugged_empty_lines.read.split("\n")
           # puts  @missing_first_stamp.to_srt
            end
            it 'should parse the file with missing first ts' do
      #                puts "some ugly debug:#{@empty_lines.lines.inspect}"
               expect(@missing_first_stamp.lines).to be_instance_of(Array)
             end
             it 'should parse the file with missing first ts and count lines correctly' do
                expect(@missing_first_stamp.lines.length).to eq(16)
             end
        end


  
  
  
  
  describe "bug parsing first line empty" do
     before(:each) do
       @bug_parsing=Subtitle.new(dump: bug_parsing, format: 'srt')
      end
      it 'should parse the file first line empty' do
#                puts "some ugly debug:#{@empty_lines.lines.inspect}"
         expect(@bug_parsing.lines).to be_instance_of(Array)
       end
       it 'should parse the file first line empty and get the correct number of lines' do
          expect(@bug_parsing.lines.length).to eq(4)
       end
    
  end
  
  describe "bugged multiple empty lines at bottom of file" do
      before(:each) do
         @problems_timestamps=Subtitle.new(dump: problems_timestamps, format: 'srt')
        # @raw_content=bugged_empty_lines.read.split("\n")
      end
      it 'should parse the file with multiple empty lines' do
         expect(@problems_timestamps.lines).to be_instance_of(Array)
      end
  end
  
 describe "bugged lines" do
     before(:each) do
        @problems_lines=Subtitle.new(dump: problems_lines, format: 'srt')
       # @raw_content=bugged_empty_lines.read.split("\n")
     end
     it 'should parse the file with multiple empty lines' do
        expect(@problems_lines.lines).to be_instance_of(Array)
     end
 end
 describe "wtf srt " do
     before(:each) do
        @wtf_srt=Subtitle.new(dump: wtf_srt, format: 'srt')
       # @raw_content=bugged_empty_lines.read.split("\n")
     end
     it 'should parse the wtf file' do
       puts "some ugly debug:#{@wtf_srt.to_srt}"
        expect(@wtf_srt.lines).to be_instance_of(Array)
     end
     it 'should parse the file wtf and get the correct number of lines' do
         expect(@wtf_srt.lines.length).to eq(4)
         puts @wtf_srt.to_webvtt
      end
   # it "should remove empty lines" do
   #   expect(@wtf_srt.to_srt).to eql("1
   #   00:00:40,700 --> 00:00:44,575
   #   Traducción por:
   #
   #   2
   #   00:00:49,501 --> 00:00:54,568
   #   THIS IS PROBLEM LINE
   #   BECAOUSE OF THIS PROBLEM
   #
   #   3
   #   00:00:56,371 --> 00:00:59,695
   #   na4na@hotmail.com
   #
   #   4
   #   00:01:49,501 --> 00:01:54,568
   #   THIS IS PROBLEM LINE
   #   BECAOUSE OF THIS PROBLEM")
   # end
 end
  
  
  
  
  describe 'Out!' do
    before(:each) do
      @sub = Subtitle.new(dump: yml_fixture, format: 'yml')
    end

    it 'should dump the object as a SRT' do
      expect(@sub.to_srt).to eql("1
00:05:26,500 --> 00:05:28,500
worth killing for...

2
00:06:00,400 --> 00:06:03,400
worth dying for...

3
00:07:00,300 --> 00:07:03,300
worth going to the hell for...

4
00:07:00,300 --> 00:07:03,300
worth going a \n line...\n")
    end
  end
end
