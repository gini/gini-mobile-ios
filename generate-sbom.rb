require 'json'

# This script generates a CycloneDX Software Bill of Materials (SBOM) for a Swift project.
#
# Prerequisites:
#  - ruby version 3.2.0 or higher
#  - nodejs version 21.0.0 or higher
#
# Arguments:
#  1. working directory: the directory of the Swift project

# Functions

def delete_package_resolved
  `rm -f Package.resolved`
end

def install_cdxgen
  `npm install @cyclonedx/cdxgen`
end

def get_project_group
  File.basename(Dir.getwd)
end

def get_project_name
  package_swift = File.read("Package.swift")
  package_swift.match(/name: "(.*)"/)[1]
end

def get_project_version
  `git tag --list --sort=taggerdate `.split.last
end

def get_sbom_output_file_name(project_name)
  "#{project_name}-sbom.json"
end

def generate_sbom(project_group, project_name, project_version)
  `npx cdxgen -t swift -o #{get_sbom_output_file_name(project_name)} --spec-version 1.4 --project-group="#{project_group}" --project-name="#{project_name}" --project-version="#{project_version}" --author="Gini GmbH"`
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

# Main

Dir.chdir(ARGV[0]) do
  delete_package_resolved()

  install_cdxgen()

  generate_sbom(get_project_group(), get_project_name(), get_project_version())

  with_sbom_json(get_sbom_output_file_name(get_project_name())) do |sbomJson|
    fix_component_type(sbomJson)

    incorrect_purl = "pkg:swift/#{get_project_group}/#{get_project_name}@unspecified"
    correct_purl = "pkg:swift/#{get_project_group}/#{get_project_name}@#{get_project_version}"
    fix_purl_and_refs(sbomJson, incorrect_purl, correct_purl)
    
    add_supplier(sbomJson)
  end
end
