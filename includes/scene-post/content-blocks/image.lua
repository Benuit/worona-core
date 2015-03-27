local worona = require "worona"

local function createImage( field )

   local image = worona.image:newImage
   {
      url         = field.url,
      real_width  = field.width,
      real_height = field.height,
      directory   = system.CachesDirectory,
      width       = display.contentWidth - 20,
      x           = display.contentWidth / 2,
      y           = 0
   }
   image.anchorY = 0
   image.y       = field.actual_y 

   field.parent:insert( image )

   field.actual_y = field.actual_y + image.contentHeight + 10
end

return createImage