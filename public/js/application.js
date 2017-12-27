$(document).ready(function (){

    $('.btn-submit').data('save-text', 'Saving...');
    $('.btn-submit').click(function(){
        $(this).button('save');
        $(this).attr("disabled", true);
        this.form.submit();
    });

    $(".clickAll").click(function () {
        if ($(".clickAll").prop("checked")) {
            $("input[name='ids[]']").each(function () {
                $(this).prop("checked", true);
            });
        }
        else {
            $("input[name='ids[]']").each(function () {
                $(this).prop("checked", false);
            });
        }
    });
});