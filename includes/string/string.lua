local worona = require "worona"

local function newStringService()

   local str = {}

   --. Splits the string with a splitting pattern. Array = that:split("string-to-split", "pattern").--
   	--. RETURN: pieces of the string that have been split as an array
   	--. ARGUMENTS: 
   	--. 	stringToSplit
   	--. 	inSplitPattern: splitting pattern
   	--. 	outResults: -
   function str:split( stringToSplit, inSplitPattern, outResults )

      if not outResults then
         outResults = { }
      end
      local theStart = 1
      local theSplitStart, theSplitEnd = string.find( stringToSplit, inSplitPattern, theStart )
      while theSplitStart do
         table.insert( outResults, string.sub( stringToSplit, theStart, theSplitStart-1 ) )
         theStart = theSplitEnd + 1
         theSplitStart, theSplitEnd = string.find( stringToSplit, inSplitPattern, theStart )
      end
      table.insert( outResults, string.sub( stringToSplit, theStart ) )
      return outResults
   end

   function str:unescape(str)
     str = string.gsub( str, '&lt;', '<' )
     str = string.gsub( str, '&gt;', '>' )
     str = string.gsub( str, '&quot;', '"' )
     str = string.gsub( str, '&apos;', "'" )
     str = string.gsub( str, '&#(%d+);', function(n) if tonumber(n) < 256 then return string.char(tonumber(n)) else return "" end end )
     str = string.gsub( str, '&#x(%d+);', function(n) if tonumber(n) < 256 then return string.char(tonumber(n,16)) else return "" end end )
     str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
     return str
   end


   return str
end
worona:do_action( "register_service", { service = "string", creator = newStringService } )