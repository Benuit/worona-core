return [[
<script>
$(function(){
    $('a').each(function(){
        var href = $(this).attr('href');
        $(this).attr('href', "/?url=" + href);
        $(this).click( function(e) {
          setInterval( function() {
            window.stop()
        }, 1 );
      });
    });
    $('img').each(function(){
      var web_src = $(this).attr('src');
      //$(this).attr('src', "sadfasdfa.jpg");
      var phone_src = "images/";

      // get filename
      var filename = web_src.replace( /.+\//, "");

      //. replace & for %3F
      filename = filename.replace( /\?/, "%3F")

      //. replace &zoom=..... for ""
      filename = filename.replace( /&.+/, "")


      // remove http:// or https://
      var url = web_src.replace( /.+:\/\//, "");

      // gets any string before a "/" character
      var re = /(.+?)\//g;
      var m;

      while ((m = re.exec(url)) !== null) {
        if (m.index === re.lastIndex) {
          re.lastIndex++;
        }
        // remove dots
        var folder = m[1].replace( /\./g, "" );
        // add it to the string
        phone_src = phone_src + folder + "/";
      }

      // finally add the filename
      phone_src = phone_src + filename;

      // use the phone_src by default
      $(this).attr('src', phone_src + "?t=" + Math.random() );

      console.log( phone_src );

      //if the image is not on the phone, use the web_src
      var check_one_time = false;
      $(this).on('error', function () {
      	if ( check_one_time === false ) {
    		$(this).attr('src', web_src);
    		check_one_time = true;
        } else {
            $(this).css({visibility: "hidden", "max-height" : "1px"});
        }   
      });
    });
});
</script>
]]
