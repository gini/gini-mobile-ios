##
# Configure git on CI machines.
#
# Usually CI machines start with a "clean slate" and we need to set
# some configurations before being able to push from the CI machine.
#
def configure_git_on_ci_machines(user_name, user_email)
  sh("git config --global user.email '#{user_email}'")
  sh("git config --global user.name '#{user_name}'")
end

##
# Pushes the branch to origin. 
# 
# If it fails due to being out-of-date it will do a pull and
# will retry the push.
#
def git_push_with_retry(branch, ui)
  sh("git push origin #{branch}") do |status, result, command|
    if status.success? == false 
      if result.include?("fetch first")
        ui.message "Pulling changes from remote and retrying the push"
        sh("git pull")
        sh(command)
      else
        ui.abort_with_message! "Push failed: #{result}"
      end 
    end
  end
end

##
# Creates a release tag with this format: `<project-id>;<version>`.
#
def git_create_release_tag(project_id, version)
  git_create_tag("#{project_id};#{version}")
end

##
# Creates an annotated tag.
#
def git_create_tag(tag)
  sh("git tag -a '#{tag}' -m '#{tag}'")
end

##
# Pushes the release tag of this format: `<project-id>;<version>`.
#
def git_push_release_tag(project_id, version)
  git_push_tag("#{project_id};#{version}")
end

##
# Pushes a tag.
#
def git_push_tag(tag)
  sh("git push origin '#{tag}'")
end

##
# Retrieve the latest release tag for the project id.
#
def get_latest_release_tag(project_id)
  sh("git tag --list '#{project_id};*' --sort=taggerdate", log: false).split.last
end

##
# Returns `true` if the folder contains changes since the last release tag of the project.
#
def did_folder_change_since_last_release(project_id, folder, ui)
  latest_release_tag = get_latest_release_tag(project_id)
  sh("git diff --quiet HEAD '#{latest_release_tag}' #{folder}", log: false) do |status, result|
      case status.exitstatus
      when 0
        false
      when 1
        true
      else
        ui.abort_with_message! "Failed to check if folder changed: #{result}"
      end
    end
end
