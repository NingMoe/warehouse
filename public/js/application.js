$(document).ready(function (){

    $('.btn-submit').data('save-text', 'Saving...');
    $('.btn-submit').click(function(){
        $(this).button('save');
        $(this).attr("disabled", true);
        this.form.submit();
    });

});