require 'xcodeproj'
project_path = '.build/swift-create-xcframework/GiniBankSDK.xcodeproj'
project = Xcodeproj::Project.open(project_path)


def addfiles (direc, current_group, main_target)
    Dir.glob(direc) do |item|
        filePath = File.join(direc, item)
        extname= direc[/\.[^\.]+$/]
        next if item == '.' or item == '.DS_Store'
        if File.directory?(item)
            if filePath.end_with?("xcassets")
                i = current_group.new_file(item)
                main_target.add_resources([i])
            else
                new_folder = File.basename(item)
                created_group = current_group.new_group(new_folder)
                addfiles("#{item}/*", created_group, main_target)
            end
        else
            i = current_group.new_file(item)
            main_target.add_resources([i])
        end
    end
end


targetBankSDK = project.targets.find { |target| target.to_s == 'GiniBankSDK' }
bankResourcesgroup = project.new_group('BankResources')
uipathBank = 'Sources/GiniBankSDK/Resources'
addfiles("#{uipathBank}/*", bankResourcesgroup, targetBankSDK)

targetCaptureSDK = project.targets.find { |target| target.to_s == 'GiniCaptureSDK' }
uipathCapture = '../../CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources'
captureResourcesgroup = project.new_group('CaptureResources')
addfiles("#{uipathCapture}/*", captureResourcesgroup, targetCaptureSDK)

project.save
