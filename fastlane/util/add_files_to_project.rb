def addFiles (direc, current_group, main_target)
    Dir.glob(direc) do |item|
        filePath = File.join(direc, item)
        next if item == '.' or item == '.DS_Store'
        if File.directory?(item)
            if filePath.end_with?("xcassets")
                i = current_group.new_file(File.expand_path(item))
                main_target.add_resources([i])
            else
                new_folder = File.basename(item)
                created_group = current_group.new_group(new_folder)
                addFiles("#{item}/*", created_group, main_target)
            end
        else
            i = current_group.new_reference(File.expand_path(item))
            main_target.add_resources([i])
        end
    end
end


