local worona = require "worona"

worona:do_action( "extend_service", { service = "ui", object = require("worona.includes.basic-tabbar.uis.newBasicTabBar") } )
worona:add_action( "before_creating_scene", require("worona.includes.basic-tabbar.items.basic-tabbar") )