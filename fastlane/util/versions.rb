##
# Extract the project version from the tag.
#
# The tag must have the following format: `<project-id>;<version>`.
#
# Halts and prints an error if the project id is not in the tag.
#
def get_project_version_from_tag(project_id, tag, ui)
  tag = normalize_tag(tag)
  components = tag.split(';')

  if !project_id.start_with?(components[0])
    ui.user_error! "The project id '#{project_id}' is not in the tag: #{tag}"
  end

  if components.size != 2
    ui.user_error! "Missing project version from the tag: #{tag}"
  end

  components[1].strip
end

##
# Extract the example app version of a project from the tag.
#
# The tag must have the following format: `<project-id>;<version>;<example-app-id>;<version>`.
#
# Halts and prints an error if the project id or example app id is not in the tag.
#
def get_example_app_version_from_tag(project_id, example_app_id, tag, ui)
  tag = normalize_tag(tag)
  components = tag.split(';')

  if components[0] != project_id
    ui.user_error! "The project id '#{project_id}' is not in the tag: #{tag}"
  end

  if components[2] != example_app_id
    ui.user_error! "The example app id '#{example_app_id}' is not in the tag: #{tag}"
  end

  if components.size != 4
    ui.user_error! "Missing example app version from the tag: #{tag}"
  end

  components[3].strip
end

def normalize_tag(tag)
  tag.delete_prefix("refs/tags/")
end

##
# Retrieve the version from the project's "#{project_id}Version.swift" file.
#
def get_project_version_from_version_file(version_file_path, ui)
  version_file = File.open("../#{version_file_path}")
  version_file.readlines.each do |line|
    if !line.start_with?('//') && line.include?("Version")
      components = line.split(" = ")

      if components.size != 2
        ui.user_error! "Wrong version line formatting: #{line}"
      end 

      version = components[1]
      break version.strip.delete('"')
    end
  end
end
