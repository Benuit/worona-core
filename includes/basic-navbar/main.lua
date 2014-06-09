local worona = require "worona"

worona:do_action( "extend_service", { service = "ui", object = require("worona.includes.basic-navbar.uis.newBasicNavBar") } )
worona:add_action( "before_creating_scene", require("worona.includes.basic-navbar.items.basic-navbar") )