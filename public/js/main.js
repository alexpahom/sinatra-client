$(document).ready(function() {
    $('.create_task_link').click(function() {
        let status = $(this).attr('data-status')
        $('#status').val(status);
    });
});

$(document).ready(function () {
    $('button#create_task').click(function(){
        let status = $('input#status').val();
        let title = $('input#title').val();
        let description = $('textarea#description').val();
        $.ajax({
            url: '/create',
            type: 'POST',
            dataType: 'json',
            data: JSON.stringify({
                status: status,
                title: title,
                description: description,
                rank: 1 // TODO: stub
            }),
            contentType: 'application/json',
            success: function(data, textStatus, jqXHR) {
                $('#exampleModalLong').close();
            },
            error: function(jqXHR, textStatus, errorThrown) {
                alert(errorThrown)
            }
        });
    });
});

$(document).ready(function () {
    $('.delete-task').click(function(){
        let id = $(this).parent().prev('.id').text();
    })
})
