##
# Extracts the required options from the options dictionary.
#
# Halts and prints an error if the required option is missing.
#
def check_and_get_options(options, required_options, ui)
  required_options.map { |required|
    if !options.key?(required)
      ui.user_error! "Missing option: #{required}"
    end
    options[required]
  }
end