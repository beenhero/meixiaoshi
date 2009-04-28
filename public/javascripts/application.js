// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function box_slide_up() {
	if ($('flash_box'))
	{
		Effect.Fade( 'flash_box', { duration: 2.0 } );
	}
}

function show_error_message() {
	setTimeout('box_slide_up()', 4000);	
}