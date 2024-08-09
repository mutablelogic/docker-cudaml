package llamacpp_test

import (
	"testing"

	// Packages
	"github.com/mutablelogic/docker-llamacpp/sys/llamacpp"
)

// 483MB
const MODEL = "https://huggingface.co/ggerganov/ggml/resolve/main/ggml-model-gpt-2-117M.bin?download=true"

func Test_llamacpp_000(t *testing.T) {
	llamacpp.Llama_backend_free()
	llamacpp.Llama_backend_free()
}

func Test_llamacpp_001(t *testing.T) {
	llamacpp.Llama_backend_free()
	t.Cleanup(func() {
		llamacpp.Llama_backend_free()
	})

	model := llamacpp.Llama_load_model_from_file("/private/tmp/ggml-model-gpt-2-117M.bin", llamacpp.Llama_model_params{})
	llamacpp.Llama_free_model(model)
}
