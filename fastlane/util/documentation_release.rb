##
# Release the documentation to the release repo for the project.
# 

def release_documentation(release_repo_url, project_folder, package_folder, repo_user, repo_password)
  Dir.chdir("../#{project_folder}/#{package_folder}/Documentation") do
   # Clear gh-pages directory 
   sh("rm -rf gh-pages")

   release_repo_url["://"] = "://#{repo_user}:#{repo_password}@"
   # Clone
   sh("git clone -b gh-pages #{release_repo_url} gh-pages")

   sh("rm -rf gh-pages/*")
   sh("mkdir gh-pages/docs")
   sh("cp -R api/. gh-pages/docs/")
  end 

  Dir.chdir("../#{project_folder}/#{package_folder}/Documentation/gh-pages") do
   sh('touch .nojekyll')
  end
   # Stage changes
   sh("git add --all")
   # Commit
   sh("git diff --quiet --exit-code --cached || git commit -m 'Release #{package_folder} documentation' --author='Team Mobile <team-mobile@gini.net>'")
   sh("git remote show origin")
   sh("git push origin gh-pages")
   #Delete gh-pages directory
   Dir.chdir("..") do
    sh("rm -rf gh-pages/")
   end
end
