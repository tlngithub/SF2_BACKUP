/**
 * Created by maximelets on 06/05/2024.
 */

({
    mobileMenuClick: function(component, event, helper) {
        console.log('clicked');
        // $('button.js-menu-btn').on( "click", function() {
            $('#wrapper').toggleClass('is-menu-open');
        // } );
    }
});