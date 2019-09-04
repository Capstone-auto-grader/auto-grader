// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/



document.addEventListener("DOMContentLoaded", function(event) {
    $(document).on("turbolinks:load", function() {
        console.log("READY")
        $('#assignment_has_resubmission').change(function() {
            $('#assignment_resub_csv').prop('disabled', !this.checked)
            $('#assignment_resub_csv').val(null)
        })
        $('#assignment_has_tests').change(function() {
            $('#assignment_assignment_test').prop('disabled', !this.checked)
            $('#assignment_assignment_test').val(null)
        })
    })
});