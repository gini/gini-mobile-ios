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
# Idempotent on reruns: if a prior run advanced `main` but failed to create the
# tag, the lane can be rerun safely — it skips the commit (nothing to stage) and
# creates the missing tag against `main`'s current HEAD. If the tag already
# exists at the expected SHA the operation is a no-op; if it exists at a
# different SHA the lane aborts loudly rather than silently retargeting it.
#
# `release_repo_url` is the HTTPS URL of the release repo (e.g.
# "https://github.com/gini/bank-sdk-ios.git"); it is reduced to the `owner/name`
# form the GitHub API expects.
#
def update_release_repo(release_repo_path, release_repo_url, version, ui)
  repo = release_repo_url.sub(%r{^https://github.com/}, '').delete_suffix('.git') # e.g. gini/bank-sdk-ios
  Dir.chdir(release_repo_path) do
    sh('git add --all')
    if sh("git diff --cached --quiet && echo same || echo changed", log: false).strip == "changed"
      sh("git commit -m 'Release version #{version}'")
      sha = push_as_signed_commit(repo, 'main', ui)
    else
      ui.message "Release content already on #{repo}/main (likely a half-published rerun); reusing current HEAD"
      sha = sh("git rev-parse HEAD", log: false).strip
    end
    # Idempotently create the version tag against the signed commit SHA.
    existing = sh("gh api repos/#{repo}/git/refs/tags/#{version} --jq .object.sha 2>/dev/null || true", log: false).strip
    if existing.empty?
      sh("gh api repos/#{repo}/git/refs -f ref=refs/tags/#{version} -f sha=#{sha}")
    elsif existing == sha
      ui.message "refs/tags/#{version} already at #{sha[0, 7]}; skipping tag creation"
    else
      ui.abort_with_message! "refs/tags/#{version} exists at #{existing[0, 7]}, expected #{sha[0, 7]} — refusing to retarget"
    end
  end
end
