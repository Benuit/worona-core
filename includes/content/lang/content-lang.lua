-- If you want to edit this file, copy and paste it to the content/lang/ folder. Then modify it there.
-- When you update the content, this file will be overwritten, so you will loose your changes.
local worona = require "worona"

return {
	--. Empty content error - simulator
	popup_simulator_empty_content_error_title = {
	   	en = "Error retrieving content",
	   	es = "Error descargando el contenido"
	},
	popup_simulator_empty_content_error_description = {
	   	en = "Sorry, the content is not available. Please check the output of:\n " .. worona.wp_url .. "/wp-json \nIt should look like http://www.worona.org/wp-json. If it doesn't check that the JSON REST API plugin is installed and activated. \n\n For more information, please visit:\n https://www.worona.org/start ",
	   	es = "Lo sentimos, el contenido no se ha podido descargar correctamente. Por favor, asegúrate de que la salida de:\n" .. worona.wp_url .. "/wp-json \n es parecido a http://www.worona.org/wp-json. Si no lo es asegúrate de que el plugin JSON REST API está instalado y activado.\n\nPara más información, por favor visita:\https://www.worona.org/start "
	},
	popup_simulator_empty_content_error_button_1 = {
		en = "Ok",
		es = "Ok"
	},

	--. Empty content error - device
	popup_device_empty_content_error_title = {
	   	en = "Error retrieving content",
	   	es = "Error descargando el contenido"
	},
	popup_device_empty_content_error_description = {
	   	en = "Sorry, the content is not available.",
	   	es = "Lo sentimos, el contenido no está disponible."
	},
	popup_device_empty_content_error_button_1 = {
		en = "Ok",
		es = "Ok"
	},

	--. Connection error (no internet) - simulator
	popup_simulator_connection_error_1_title = {
	   	en = "Connection Error",
	   	es = "Error de conexión"
	},
	popup_simulator_connection_error_1_description = {
	   	en = "Sorry, the content is not available. It looks like you don't have Internet access or Corona Simulator cannot connect to the internet. Please contact http://coronalabs.com/ to solve this issue.",
	   	es = "El contenido no se ha podido descargar debido a un error de conexión. Parece que o bien no tienes conexión a Internet o Corona Simulator no puede conectarse a internet. Por favor, contacta con http://coronalabs.com/ para resolver este problema."
	},
	popup_simulator_connection_error_1_button_1 = {
		en = "Ok",
		es = "Ok"
	},
	popup_simulator_connection_error_1_button_2 = {
		en = "Try again",
		es = "Intentar de nuevo"
	},

	--. Connection error (no internet) - device
	popup_device_connection_error_1_title = {
	   	en = "Connection Error",
	   	es = "Error de conexión"
	},
	popup_device_connection_error_1_description = {
	   	en = "Sorry, the content is not available. Please check your internet connection.",
	   	es = "El contenido no se ha podido descargar debido a un error de conexión. Por favor comprueba tu conexión a internet."
	},
	popup_device_connection_error_1_button_1 = {
		en = "Ok",
		es = "Ok"
	},
	popup_device_connection_error_1_button_2 = {
		en = "Try again",
		es = "Intentar de nuevo"
	},

	--. Connection error (internet Ok) - simulator
	popup_simulator_connection_error_2_title = {
	   	en = "Connection Error",
	   	es = "Error de conexión"
	},
	popup_simulator_connection_error_2_description = {
	   	en = "Sorry, the content is not available. Internet connection is available, but cannot connect to:\n" .. worona.wp_url .. "\nPlease check that you have correctly entered the url in the main.lua file and that your site is up and running.",
	   	es = "El contenido no se ha podido descargar debido a un error de conexión. Parece que la conexión a internet está activa, pero no podemos conectar con\n" .. worona.wp_url .. "\nPor favor, revisa que has introducido correctamente la url en el archivo main.lua y que tu sitio funciona correctamente."
	},
	popup_simulator_connection_error_2_button_1 = {
		en = "Ok",
		es = "Ok"
	},
	popup_simulator_connection_error_2_button_2 = {
		en = "Try again",
		es = "Intentar de nuevo"
	},

	--. Connection error (internet Ok) - device
	popup_device_connection_error_2_title = {
	   	en = "Connection Error",
	   	es = "Error de conexión"
	},
	popup_device_connection_error_2_description = {
	   	en = "Sorry, the content is not available.",
	   	es = "El contenido no se ha podido descargar debido a un error de conexión."
	},
	popup_device_connection_error_2_button_1 = {
		en = "Ok",
		es = "Ok"
	},
	popup_device_connection_error_2_button_2 = {
		en = "Try again",
		es = "Intentar de nuevo"
	}
	
	
}