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
