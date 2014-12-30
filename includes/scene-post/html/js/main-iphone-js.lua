return [[
<script>
$(function(){
	$('a').each(function(){
		var href = $(this).attr('href');
   	$(this).attr('href', 'javascript:');
   	$(this).click( function(e) {
   		e.preventDefault();
          var xobj = new XMLHttpRequest();
          xobj.open('GET', "http://localhost:1024?url=" + href, true);
          xobj.send(null);
   	});
	});
	$('img').each(function(){
		var web_src = $(this).attr('src');
		$(this).attr('src', 'http://localhost:1024/img.jpg?img=' + web_src);
		// if the image is not on the phone, use the web_src
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
