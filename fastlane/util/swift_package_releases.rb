##
# Checkout release repo for the project.
# 
# Returns the relative ath to the release repo.
#
def checkout_release_repo(release_repo_url, repo_user, repo_password)
  sh("rm -rf release-repo")
  release_repo_url["://"] = "://#{repo_user}:#{repo_password}@"
  sh("git clone #{release_repo_url} release-repo")
  "release-repo"
end

def copy_swift_package_to_release_repo(release_repo_path, project_folder, package_folder)
  Dir.chdir(release_repo_path) do
    # Clear out everything
    sh("git rm -rf . && git clean -fd")
    # Copy swift package contents
    sh("cp -R ../../#{project_folder}/#{package_folder}/ .")
    # Use the release Package.swift
    sh("mv -f Package-release.swift Package.swift || true")
  end
end

def update_release_repo(release_repo_path, version)
  Dir.chdir(release_repo_path) do
    # Stage changes
    sh('git add --all')
    # Commit
    sh("git commit -m 'Release version #{version}' --author='Team Mobile Schorsch <team-mobile@gini.net>'")
    # Tag
    sh("git tag -a -m 'Release version #{version}' #{version}")
    # Push
    sh('git push --tags && git push')
  end
end
