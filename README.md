A minimal wrapper around the code generator and linker for Clean, allowing ABC-assembly to be hand-written and compiled into an executable.

Requires Clean (clean.cs.ru.nl) be installed and `$CLEAN_HOME` be set properly.

Usage: `abc.sh input_file -o=output_file --clmlink=<clmlink_args> --syslink=<system_linker_args> --codegen=<cg_args>`

The generated executable takes the same RTS arguments a normal Clean executable does.

Features:

 - respects `$TMPDIR` if set
