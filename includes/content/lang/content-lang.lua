-- If you want to edit this file, copy and paste it to the content/lang/ folder. Then modify it there.
-- When you update the content, this file will be overwritten, so you will loose your changes.
local worona = require "worona"

return {
	popup_empty_content_error_title = {
	   	en = "Error retrieving content",
	   	es = "Error descargando el contenido"
	},
	popup_empty_content_error_description = {
	   	en = "Sorry, the content is not available. Please check the json file in:\n " .. worona.wp_url .. "/wp-json/posts \nIs the JSON REST API plugin installed and activated? If not, please do so in your WordPress admin panel.\n\n For more information, please visit:\n http://worona.webflow.com/start ",
	   	es = "Lo sentimos, el contenido no se ha podido descargar correctamente. Por favor, asegúrate de que se muestra correctamente el archivo json en:\n" .. worona.wp_url .. "/wp-json/posts \n ¿Está el plugin JSON REST API instalado y activado? Si no es así, por favor hazlo en tu panel de administrador de WordPress.\n\nPara más información, por favor visita:\nhttp://worona.webflow.com/start "
	},
	popup_empty_content_error_button_1 = {
		en = "Ok",
		es = "Ok"
	},
	popup_connection_error_1_title = {
	   	en = "Connection Error",
	   	es = "Error de conexión"
	},
	popup_connection_error_1_description = {
	   	en = "Sorry, the content is not available. It looks like Corona Simulator cannot connect to the internet. Please contact http://coronalabs.com/ to solve this issue.",
	   	es = "El contenido no se ha podido descargar debido a un error de conexión. Parece que Corona Simulator no puede conectarse a internet. Por favor, contacta con http://coronalabs.com/ para resolver este problema."
	},
	popup_connection_error_1_button_1 = {
		en = "Ok",
		es = "Ok"
	},
	popup_connection_error_1_button_2 = {
		en = "Try again",
		es = "Intentar de nuevo"
	},
	popup_connection_error_2_title = {
	   	en = "Connection Error",
	   	es = "Error de conexión"
	},
	popup_connection_error_2_description = {
	   	en = "Sorry, the content is not available. Internet connection is available, but cannot connect to:\n" .. worona.wp_url .. "\nPlease check your WordPress site configuration.",
	   	es = "El contenido no se ha podido descargar debido a un error de conexión. Parece que la conexión a internet está activa, pero no podemos conectar con\n" .. worona.wp_url .. "\nPor favor, revisa la configuración."
	},
	popup_connection_error_2_button_1 = {
		en = "Ok",
		es = "Ok"
	},
	popup_connection_error_2_button_2 = {
		en = "Try again",
		es = "Intentar de nuevo"
	}
	
	
}