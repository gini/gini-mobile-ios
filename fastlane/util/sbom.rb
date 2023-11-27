require 'json'

##
# Generates a CycloneDX Software Bill of Materials (SBOM) for a Swift package.
# 
# Returns the path to the generated SBOM file.
# 
# Prerequisites:
#  - nodejs version 21.0.0 or higher available in the PATH
#
def generate_sbom(swift_package_dir)
  Dir.chdir(swift_package_dir) do
    setup_cdxgen()
  
    delete_package_resolved()

    sbom_output_file_name = get_sbom_output_file_name(get_project_name())

    generate_sbom_with_cdxgen(sbom_output_file_name, get_project_group(), get_project_name(), get_project_version())
  
    with_sbom_json(sbom_output_file_name) do |sbomJson|
      fix_component_type(sbomJson)
  
      incorrect_purl = "pkg:swift/#{get_project_group}/#{get_project_name}@unspecified"
      correct_purl = "pkg:swift/#{get_project_group}/#{get_project_name}@#{get_project_version}"
      fix_purl_and_refs(sbomJson, incorrect_purl, correct_purl)
      
      add_supplier(sbomJson)
    end
  
    File.join(swift_package_dir, sbom_output_file_name)
  end
end

def delete_package_resolved
  sh("rm -f Package.resolved")
end

def setup_cdxgen
  is_installed = sh("cdxgen --help}", log: false) do |status, result|
    case status.exitstatus
    when 0
      true
    else
      false
    end
  end

  if !is_installed then sh("npm install -g @cyclonedx/cdxgen") end
end

def get_project_group
  File.basename(Dir.getwd)
end

def get_project_name
  package_swift = File.read("Package.swift")
  package_swift.match(/name: "(.*)"/)[1]
end

def get_project_version
  sh("git tag --list --sort=taggerdate").split.last
end

def get_sbom_output_file_name(project_name)
  "#{project_name}-sbom.json"
end

def generate_sbom_with_cdxgen(sbom_output_file_name, project_group, project_name, project_version)
  sh("cdxgen -t swift -o #{sbom_output_file_name} --spec-version 1.4 --project-group='#{project_group}' --project-name='#{project_name}' --project-version='#{project_version}' --author='Gini GmbH'")
end

def fix_component_type(sbomJson)
  sbomJson["metadata"]["component"]["type"] = "library"
  File.write("sbom.json", JSON.pretty_generate(sbomJson))
end

def fix_purl_and_refs(sbomJson, incorrect_purl, correct_purl)
  sbomJson["metadata"]["component"]["purl"] = correct_purl
  sbomJson["metadata"]["component"]["bom-ref"] = correct_purl

  sbomJson["dependencies"].each do |dependency|
    if dependency["ref"] == incorrect_purl
      dependency["ref"] = correct_purl
    end
  end
end

def with_sbom_json(file_name)
  sbomJson = JSON.parse(File.read(file_name))
  yield(sbomJson)
  File.write(file_name, JSON.pretty_generate(sbomJson))
end

def add_supplier(sbomJson)
  sbomJson["metadata"]["supplier"] = { 
    "name" => "Gini GmbH", 
    "url" => [ "https://gini.net" ] 
  }
end
