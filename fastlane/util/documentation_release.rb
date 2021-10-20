##
# Release the documentation to the release repo for the project.
# 

def release_documentation(release_repo_url)
  Dir.chdir(Documents) do
   # Clear gh-pages directory 
   sh("rm -rf gh-pages")
   # Clone
   sh("git clone -b gh-pages #{release_repo_url} gh-pages")

   sh("rm -rf gh-pages/*")
   sh("mkdir gh-pages/docs")
   sh("cp -R api/. gh-pages/docs/")
  end 

  Dir.chdir(gh-pages) do
   sh('touch .nojekyll')
  end
   # Stage changes
   sh("git add .")
   # Commit
   sh("git commit -a -m 'Updated documentation' --author='Team Mobile Schorsch <team-mobile@gini.net>'")
   # Push
   sh("git push")
   #Delete gh-pages directory
   sh("cd ..")
   sh("rm -rf gh-pages/")
end
