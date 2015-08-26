$(document).on('change', '[data-toggle-checkboxes]', function() {
  var $this = $(this);
  var target = $this.data('toggleCheckboxes');
  var $targets = $('[data-toggle-checkboxes-'+target+']');
  var isChecked = $this.is(':checked');

  if (isChecked) $targets.prop('checked', 'checked');
  else $targets.prop('checked', false);
});