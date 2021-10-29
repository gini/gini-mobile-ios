Integrate the Gini Capture SDK in a Xamarin project
=============================

Requirements
----------------------

  - [Xamapod](https://github.com/kikettas/xamapod)
  - Visual Studio


1. Creating the fat libraries and the binding files
----------------------

After cloning the **Xamapod** tool repository and installing all its dependencies, run the following command:
```bash
sh build -p GiniCapture -s Networking -l https://github.com/gini/gini-podspecs,https://github.com/CocoaPods/Specs.git
```

The `-l` option ensures that the tool refers to our cocoapods repository to which the Gini Capture SDK is deployed.

Check the [Integration guide](integration.html) for further information about the possible subspecs (`-s`).

Once it finishes, you can find all the generated binding files inside the **Generated** folder.


2. Creating a binding library
---------------------------------
Open your app project in _Visual Studio_ and create a binding library.
<center><img src="img/Xamarin/create_new_project.png" border="1"/></center>
<center><img src="img/Xamarin/create_binding_library.png" border="1"/></center>

Copy all the fat libraries (`.framework`) generated in the previous step and paste
them somewhere inside the created binding library directory (this will prevent any
issues with the linking). Add them to the binding library in Visual Studio, as follows:

<center><img src="img/Xamarin/add_fat_libraries.png" border="1"/></center>

Go back to the **Generated** folder, copy the content of the **ApiDefinitions.cs** file and paste it inside the **ApiDefinition.cs** file in the Binding library. Do the same for the **StructsAndEnums.cs** file.

<center><img src="img/Xamarin/paste_api_definitions_content.png" border="1"/></center>

At this point, if you try to build the binding library, it will give you some errors because sometimes _Objective sharpie_ cannot find the proper bindings ([here](https://docs.microsoft.com/en-us/xamarin/cross-platform/macios/binding/objective-sharpie/) you have a complete reference where you can find the correct definition for every type).
A working example of these definition files can be downloaded [here](xamarin-binding-files-example/gvl-xamarin-definitions-files.zip).

3. Reference the Binding library in your app project
---------------------------------

Now that the binding library has been built, it has to be referenced inside your app. To do so, add it as a reference.

<center><img src="img/Xamarin/edit_references.png" border="1"/></center>
<center><img src="img/Xamarin/check_reference.png" border="1"/></center>

It is necessary to add the Swift library packages in your app (and not in the binding library). You can find the required libraries in the **Xamapod** build ouput.
<center><img src="img/Xamarin/nuget_swift_packages.png" border="1"/></center>
