# ==============================================================================
# GDB Configuration File (.gdbinit) for C, C++, and Rust Debugging
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. INTERFACE & ASSEMBLY READABILITY
# ------------------------------------------------------------------------------

# Use Intel syntax for assembly (e.g., 'mov eax, [ebx]') instead of AT&T syntax.
# Most developers find this much more readable than AT&T's 'movl (%ebx), %eax'.
# set disassembly-flavor intel

# Format structures and arrays with clean indentation and line breaks instead
# of condensing them into a single unreadable line.
set print pretty on

# Display derived/dynamic types instead of declared types for C++ and Rust
# trait objects. This lets you see the actual underlying object type.
set print object on

# Print array indices alongside their values, making it easier to parse 
# large data buffers or vectors.
set print array-indexes on


# ------------------------------------------------------------------------------
# 2. SYMBOL DEMANGLING & LANGUAGE SUPPORT
# ------------------------------------------------------------------------------

# Automatically convert mangled C++ and Rust internal symbols back into 
# human-readable source names.
set print demangle on

# Automatically detect the language (C, C++, or Rust) and use the correct 
# demangling style.
set demangle-style auto


# ------------------------------------------------------------------------------
# 3. MEMORY, BUFFER & STRING PRINTING
# ------------------------------------------------------------------------------

# Increase the maximum number of array or vector elements GDB displays before 
# truncating with '...'. Prevents cutting off your data prematurely.
set print elements 200

# High threshold for compressing repeated identical values in arrays. 
# GDB only collapses identical values if there are 10 or more in a row.
set print repeats 10

# Stops printing C-strings ('char*') the moment a null terminator '\0' is hit,
# which prevents dumping arbitrary memory into your console.
set print null-stop on

# Prevents the printing of complex, multi-line arguments in backtraces.
# Restricts frame arguments to simple scalar values to keep backtraces clean.
set print frame-arguments scalars


# ------------------------------------------------------------------------------
# 4. STEPPING, BREAKPOINTS & BACKTRACES
# ------------------------------------------------------------------------------

# Instructs GDB to step into functions that do not have debug symbols. 
# Turn this off ('off') if you prefer to skip over functions without debug info.
set step-mode off

# Allows setting breakpoints on functions that aren't loaded yet (e.g., in 
# dynamic libraries that are loaded during runtime via dlopen).
set breakpoint pending on

# Limits how deep backtraces can go. Prevents infinite recursion loops
# from hanging GDB when printing the call stack.
set backtrace limit 30


# ------------------------------------------------------------------------------
# 5. COMMAND HISTORY
# ------------------------------------------------------------------------------

# Saves your GDB command history to a file so it persists across sessions.
set history save on

# Keeps up to 10,000 commands in your GDB command history file.
set history size 10000

# Specifies the file where GDB saves command history.
set history filename ~/.gdb_history

# Prevents saving duplicate commands in a row to the history file.
set history remove-duplicates 1


# ------------------------------------------------------------------------------
# 6. PERFORMANCE & OPTIMIZATION
# ------------------------------------------------------------------------------

# Speeds up symbol loading for massive C++ / Rust binaries by only loading 
# symbols when they are needed.
# set symbol-loading-mode on


# ------------------------------------------------------------------------------
# 7. AUTOMATIC RUST PRETTY-PRINTER LOADING (Python)
# ------------------------------------------------------------------------------
# This snippet automatically detects the Rust sysroot and loads native Rust 
# visualizers (pretty-printers for Strings, Vecs, etc.) even when running
# raw 'gdb' instead of 'rust-gdb'.
#
# python
# import os
# import sys
# import gdb
#
# # Find and load the native Rust type visualizers
# for path in os.popen("rustc --print sysroot 2>/dev/null").read().splitlines():
#     pp_path = os.path.join(path, "lib", "rustlib", "etc")
#     if os.path.exists(pp_path):
#         if pp_path not in sys.path:
#             sys.path.insert(0, pp_path)
#         try:
#             import gdb_lookup
#             # Register visualizers for the current debugging session
#             gdb_lookup.register_printers(gdb.current_objfile())
#         except ImportError:
#             pass
# end
