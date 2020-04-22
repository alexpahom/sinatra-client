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
            dataType: 'script',
            data: JSON.stringify({
                status: status,
                title: title,
                description: description,
                rank: 1 // TODO: stub
            }),
            contentType: 'application/json'
        });
    });
});

$(document).ready(function () {
    $('.delete-task a').click(function(){
        let id = $(this).parent().prev('.id').text();
        $.ajax({
            url: `/update/${id}`,
            type: 'DELETE',
            success: function(data, textStatus, jqXHR) {

            },
            error: function(jqXHR, textStatus, errorThrown) {
                alert(errorThrown)
            }
        })
    })
})
