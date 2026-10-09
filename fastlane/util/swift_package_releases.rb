##
# Checkout release repo for the project.
# 
# Returns the relative path to the release repo.
#
def checkout_release_repo(release_repo_url)
  sh("rm -rf release-repo")
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

##
# Commits the staged release contents and publishes them to `main` of the release
# repo as a signed commit (via `push_as_signed_commit`), then creates the version
# tag on the remote via the GitHub API so it points at the signed commit.
#
# `release_repo_url` is the HTTPS URL of the release repo (e.g.
# "https://github.com/gini/bank-sdk-ios.git"); it is reduced to the `owner/name`
# form the GitHub API expects.
#
def update_release_repo(release_repo_path, release_repo_url, version, ui)
  repo = release_repo_url.sub(%r{^https://github.com/}, '').delete_suffix('.git') # e.g. gini/bank-sdk-ios
  Dir.chdir(release_repo_path) do
    sh('git add --all')
    sh("git commit -m 'Release version #{version}'")
    sha = push_as_signed_commit(repo, 'main', ui)
    sh("gh api repos/#{repo}/git/refs -f ref=refs/tags/#{version} -f sha=#{sha}")
  end
end
