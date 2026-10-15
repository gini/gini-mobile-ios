#!/usr/bin/env ruby
# frozen_string_literal: true
#
# add_uitest_target.rb — add the GiniHealthSDKExampleUITests target to
# GiniHealthSDKExample.xcodeproj. Idempotent: re-running the script after the
# target already exists is a no-op (it refreshes file references and leaves
# the target intact).
#
# This mirrors the structure the BankSDK team ships for its UITests target —
# bundle id `gini.net.GiniHealthSDKExampleUITests`, deployment target 17.0
# (Health SDK's minimum), hosts `GiniHealthSDKExample`, links and copies
# BrowserStackTestHelper.xcframework, picks up every .swift under the test
# folder and the three fixture files under TestSamples/TestSamplesForBS/.
#
# Usage (from the repository root):
#   ruby HealthSDK/GiniHealthSDKExample/GiniHealthSDKExampleUITests/Scripts/add_uitest_target.rb

require 'xcodeproj'

PROJECT_PATH = 'HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample.xcodeproj'
TARGET_NAME = 'GiniHealthSDKExampleUITests'
TEST_FOLDER = 'HealthSDK/GiniHealthSDKExample/GiniHealthSDKExampleUITests'
HOST_APP_NAME = 'GiniHealthSDKExample'

proj = Xcodeproj::Project.open(PROJECT_PATH)
host = proj.targets.find { |t| t.name == HOST_APP_NAME } or
  abort("#{HOST_APP_NAME} target not found in #{PROJECT_PATH}")

# Reuse an existing target if present — safe to re-run after Xcode UI tweaks.
existing = proj.targets.find { |t| t.name == TARGET_NAME }
target = existing || proj.new_target(:ui_test_bundle,
                                     TARGET_NAME,
                                     :ios,
                                     '17.0',
                                     proj.products_group,
                                     :swift)

# Build settings — mirror BankSDK's UITest target.
target.build_configuration_list.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'gini.net.GiniHealthSDKExampleUITests'
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['TEST_TARGET_NAME'] = HOST_APP_NAME
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  settings['SWIFT_VERSION'] = '5.0'
  settings['DEVELOPMENT_TEAM'] = 'JA825X8F7Z'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
end

# Dependency on the host app — Xcode requires this for UI-test bundles.
unless target.dependencies.any? { |d| d.target == host }
  target.add_dependency(host)
end

# File-group tree: GiniHealthSDKExampleUITests/{Screens,TestSamples/TestSamplesForBS,Frameworks}.
main_group = proj.main_group
# Reuse any existing group with the test target's name; otherwise create one at the Health group.
health_group = main_group.find_subpath('HealthSDK/GiniHealthSDKExample', true)
ut_group = health_group.find_subpath(TARGET_NAME, true)
ut_group.set_source_tree('<group>')
ut_group.set_path(TARGET_NAME)
screens_group = ut_group.find_subpath('Screens', true)
screens_group.set_source_tree('<group>')
screens_group.set_path('Screens')
samples_group = ut_group.find_subpath('TestSamples/TestSamplesForBS', true)
samples_group.set_source_tree('<group>')
samples_group.set_path('TestSamples/TestSamplesForBS')
frameworks_group = ut_group.find_subpath('Frameworks', true)
frameworks_group.set_source_tree('<group>')
frameworks_group.set_path('Frameworks')

# Helper that reuses an existing reference matching the given path, or creates one.
def ensure_file_ref(group, path)
  existing = group.files.find { |f| f.path == path }
  return existing if existing
  group.new_reference(path)
end

# Swift sources — add every .swift under the test folder (minus Scripts, which is tooling only).
sources = {
  ut_group => Dir.glob("#{TEST_FOLDER}/*.swift").map { |p| File.basename(p) },
  screens_group => Dir.glob("#{TEST_FOLDER}/Screens/*.swift").map { |p| File.basename(p) },
}

sources.each do |group, filenames|
  filenames.each do |name|
    ref = ensure_file_ref(group, name)
    unless target.source_build_phase.files_references.include?(ref)
      target.add_file_references([ref])
    end
  end
end

# Resource files — the three fixture files.
%w[testMedInvoice.pdf testMedInvoice.png multi-invoice.pdf].each do |name|
  ref = ensure_file_ref(samples_group, name)
  unless target.resources_build_phase.files_references.include?(ref)
    target.add_resources([ref])
  end
end

# Framework — link BrowserStackTestHelper.xcframework and copy it (code-signed) into the test runner.
framework_ref = ensure_file_ref(frameworks_group, 'BrowserStackTestHelper.xcframework')
unless target.frameworks_build_phase.files_references.include?(framework_ref)
  target.frameworks_build_phase.add_file_reference(framework_ref)
end

copy_phase = target.build_phases.find { |p| p.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) && p.symbol_dst_subfolder_spec == :frameworks }
copy_phase ||= begin
  phase = target.new_copy_files_build_phase('Embed Frameworks')
  phase.symbol_dst_subfolder_spec = :frameworks
  target.build_phases << phase unless target.build_phases.include?(phase)
  phase
end
unless copy_phase.files_references.include?(framework_ref)
  build_file = copy_phase.add_file_reference(framework_ref)
  build_file.settings = { 'ATTRIBUTES' => %w[CodeSignOnCopy RemoveHeadersOnCopy] }
end

proj.save
puts "Added/refreshed #{TARGET_NAME} in #{PROJECT_PATH}"
puts "Sources   : #{target.source_build_phase.files_references.count}"
puts "Resources : #{target.resources_build_phase.files_references.count}"
puts "Frameworks: #{target.frameworks_build_phase.files_references.count}"
