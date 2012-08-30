# Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

# http://www.ruby-forum.com/topic/4374530
def add_define(name)
  $defs.push("-D#{name}")
end

# Generate faster code
add_define "FULL_UNROLL"

# Give it a name
extension_name = 'fast_aes'

# The destination
dir_config(extension_name)

# Do the work
create_makefile(extension_name)
