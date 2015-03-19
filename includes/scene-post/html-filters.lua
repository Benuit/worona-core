local worona = require "worona"

local function change_img_src(html)
  return string.gsub(html, '(<img.-)src=', '%1data-src=')
end
worona:add_filter("html_before_render", change_img_src)