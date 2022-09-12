//+build linux, darwin, freebsd, openbsd
package filepath

when ODIN_OS == .Darwin {
	foreign import libc "System.framework"
} else {
	foreign import libc "system:c"
}

import "core:runtime"
import "core:strings"

SEPARATOR :: '/'
SEPARATOR_STRING :: `/`
LIST_SEPARATOR :: ':'

is_reserved_name :: proc(path: string) -> bool {
	return false
}

is_abs :: proc(path: string) -> bool {
	return strings.has_prefix(path, "/")
}

abs :: proc(path: string, allocator := context.allocator) -> (res: string, ok: bool, err: runtime.Allocator_Error) {
	rel := path
	if rel == "" {
		rel = "."
	}
	rel_cstr := strings.clone_to_cstring(rel, context.temp_allocator) or_return
	path_ptr := realpath(rel_cstr, nil)
	if path_ptr == nil {
		return "", __error()^ == 0, nil
	}
	defer _unix_free(path_ptr)

	path_cstr := cstring(path_ptr)
	path_str := strings.clone(string(path_cstr), allocator) or_return
	return path_str, true, nil
}

join :: proc(elems: []string, allocator := context.allocator) -> (res: string, err: runtime.Allocator_Error) {
	for e, i in elems {
		if e != "" {
			p := strings.join(elems[i:], SEPARATOR_STRING, context.temp_allocator) or_return
			return clean(p, allocator)
		}
	}
	return "", nil
}

@(private)
foreign libc {
	realpath :: proc(path: cstring, resolved_path: rawptr) -> rawptr ---
	@(link_name="free") _unix_free :: proc(ptr: rawptr) ---

}
when ODIN_OS == .Darwin {
	@(private)
	foreign libc {
		@(link_name="__error")          __error :: proc() -> ^i32 ---
	}
} else when ODIN_OS == .OpenBSD {
	@(private)
	foreign libc {
		@(link_name="__errno")		__error :: proc() -> ^i32 ---
	}
} else {
	@(private)
	foreign libc {
		@(link_name="__errno_location") __error :: proc() -> ^i32 ---
	}
}
