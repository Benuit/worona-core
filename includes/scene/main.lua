local worona = require "worona"

worona:do_action( "register_service", { service = "scene", creator = require("worona.includes.scene.services.scene") } )