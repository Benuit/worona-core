local worona = require "worona"

worona:do_action( "register_service", { service = "image", creator = require( "worona.includes.image.services.image" ) } )