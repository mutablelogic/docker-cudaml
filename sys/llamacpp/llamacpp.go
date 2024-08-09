package llamacpp

///////////////////////////////////////////////////////////////////////////////
// CGO

/*
#cgo pkg-config: llamacpp
#include <llama.h>
#include <stdlib.h>
*/
import "C"
import "unsafe"

///////////////////////////////////////////////////////////////////////////////
// TYPES

type (
	Ggml_numa_strategy C.enum_ggml_numa_strategy
	Llama_model        C.struct_llama_model
	Llama_model_params C.struct_llama_model_params
)

///////////////////////////////////////////////////////////////////////////////
// GLOBALS

const (
	GGML_NUMA_STRATEGY_DISABLED   = C.GGML_NUMA_STRATEGY_DISABLED
	GGML_NUMA_STRATEGY_DISTRIBUTE = C.GGML_NUMA_STRATEGY_DISTRIBUTE
	GGML_NUMA_STRATEGY_ISOLATE    = C.GGML_NUMA_STRATEGY_ISOLATE
	GGML_NUMA_STRATEGY_NUMACTL    = C.GGML_NUMA_STRATEGY_NUMACTL
	GGML_NUMA_STRATEGY_MIRROR     = C.GGML_NUMA_STRATEGY_MIRROR
)

///////////////////////////////////////////////////////////////////////////////
// LIFECYCLE

// Initialize the llama + ggml backend. If numa is true, use NUMA optimizations
// Call once at the start of the program
func Llama_backend_init() {
	C.llama_backend_init()
}

func Llama_numa_init(numa Ggml_numa_strategy) {
	C.llama_numa_init(C.enum_ggml_numa_strategy(numa))
}

// Call once at the end of the program - currently only used for MPI
func Llama_backend_free() {
	C.llama_backend_free()
}

// Load a model from a file
func Llama_load_model_from_file(path string, params Llama_model_params) *Llama_model {
	cPath := C.CString(path)
	defer C.free(unsafe.Pointer(cPath))
	return (*Llama_model)(C.llama_load_model_from_file(cPath, C.struct_llama_model_params(params)))
}

// Free a model
func Llama_free_model(model *Llama_model) {
	C.llama_free_model((*C.struct_llama_model)(model))
}
