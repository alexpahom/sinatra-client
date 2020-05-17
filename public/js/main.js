// When user clicks 'add new task', column status is injected into modal
$(document).ready(function() {
    $('.create_task_link').click(function() {
        let status = $(this).attr('data-status')
        $('#status').val(status);
    });
});

// POST request for task creation
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

// DELETE request for task deletion
$(function () {
    $(document).on('click', '.delete-task a', function(){
        let id = $(this).parent().prevAll('.id').text();
        $.ajax({
            url: `/update/${id}`,
            type: 'DELETE'
        });
    });
});

// Drag-n-drop processing
$(function () {
    // PATCH when dropped correctly
    $('ul').sortable({
        connectWith: 'ul',
        update: function (event, ui) {
            const id = ui.item.find('.id').text();
            const status = ui.item.closest('ul').attr('data-status');
            console.log('Status: ' + status + ' ID: ' + id);
            if (ui.sender) return;
            $.ajax({
                url: `/update/${id}`,
                type: 'PATCH',
                dataType: 'script',
                data: JSON.stringify({
                    status: status
                }),
                contentType: 'application/json',
                error: function (xhr, status, errorMessage) {
                    $('ul').sortable('cancel');
                }
            });
        },
        // When dragging is started
        start: function (event, ui) {
            ui.item.css({
                'transform': 'rotate(3deg) scale(1.05)',
                'transition-duration': '1s',
                'transition-property': 'transform',
                'box-shadow': '0 5px 9px 5px rgba(140,140,140,0.6)'
            });
        },
        // When dragging is completed
        stop: function (event, ui) {
            ui.item.css({
                'transform': '',
                'box-shadow': ''
            });
        }
    })
})

// PATCH request for task editing
$(function () {
    $('#update_task').click(function () {
        const id = $('#id').val();
        const title = $('#title').val();
        const desc = $('#description').val();
        $.ajax({
            url: `/update/${id}`,
            type: 'PATCH',
            dataType: 'script',
            data: JSON.stringify({
                title: title,
                description: desc
            }),
            contentType: 'application/json',
            success: function (text, status, xhr) {
                $('#bsModal').modal('toggle');
            }
        });
    });
});

// Shows modal for task editing and populates the values
$(function () {
    $('.show-task').click(function () {
        const root = $(this).closest('li');
        const title = $(root).find('.title').text();
        const desc = $(root).find('.description').text();
        const id = $(root).find('.id').text();
        $('#title').val(title);
        $('#description').text(desc);
        $('#id').val(id);
        $('.modal-title').text('Update Task');
        $('#update_task').removeAttr('hidden');
        $('#create_task').attr({'hidden': 'true'});
    });
});

// As bootstrap modal works for both creation and update,
// here buttons and other text is reset
$(function () {
    $('.create_task_link').on('click', function () {
        $('#title').val('');
        $('#description').text('');
        $('.modal-title').text('Create Task');
        $('#update_task').attr({'hidden': 'true'});
        $('#create_task').removeAttr('hidden');
    })
})
