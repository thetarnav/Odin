//+private
//+build wasi
package time

import wasi "core:sys/wasm/wasi"

_IS_SUPPORTED :: true

_now :: proc "contextless" () -> Time {
	res, _ := wasi.clock_res_get(wasi.CLOCK_REALTIME)
	ns, _ := wasi.clock_time_get(wasi.CLOCK_REALTIME, res)
	return Time{_nsec = i64(ns)}
}

_sleep :: proc "contextless" (d: Duration) {
}

_tick_now :: proc "contextless" () -> Tick {
	res, _ := wasi.clock_res_get(wasi.CLOCK_MONOTONIC)
	ns, _ := wasi.clock_time_get(wasi.CLOCK_MONOTONIC, res)
	return Tick{_nsec = i64(ns)}
}


_yield :: proc "contextless" () {
	wasi.sched_yield()
}