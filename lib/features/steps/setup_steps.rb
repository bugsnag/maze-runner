# @!group Setup steps

# Creates a new project in bugsnag
# @step_input name [String] The name of the project
# @step_input type [String] The type of the project, full list can be found in the Bugsnag API documentation
# https://bugsnagapiv2.docs.apiary.io/#reference/projects/projects/create-a-project-in-an-organization
Given('I create a new project {string} with type {string}') do |name, type|
  org_id = data_access_api.get_first_org_id
  project = data_access_api.create_project(org_id, name, type)
  project_id = project['id']
  data_access_api.set_project_id(project_id)
  api_key = data_access_api.get_project_api_key(project_id)
  Maze.config.bugsnag_repeater_api_key = api_key
  Maze.config.bugsnag_data_access_project_id = project_id
end
