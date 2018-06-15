#
#
#
class govuk_env_sync(
  $tasks = {},
  $user = 'govuk-backup',
) {

  create_resources(govuk_env_sync::task, $tasks)
}
