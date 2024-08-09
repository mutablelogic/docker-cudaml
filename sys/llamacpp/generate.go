package llamacpp

///////////////////////////////////////////////////////////////////////////////
// CGO

/*
#cgo pkg-config: llamacpp
#cgo darwin pkg-config: llamacpp-darwin
*/
import "C"

// Generate the llamacpp pkg-config files
// Setting the prefix to the base of the repository

//go:generate go run ../pkg-config --version "0.0.0" --libs "-framework Accelerate -framework Metal -framework Foundation -framework CoreGraphics" llamacpp-darwin.pc
//go:generate go run ../pkg-config --version "0.0.0" --prefix "../.." --cflags "-I$DOLLAR{prefix}/llama.cpp/include -I$DOLLAR{prefix}/llama.cpp/ggml/include" --libs "-L$DOLLAR{prefix}/llama.cpp -lllama -lggml -lm -lstdc++" llamacpp.pc
