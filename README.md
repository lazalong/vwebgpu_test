
Using windows webgpu_64_win_gnu
version 29.0.1.1 June 2026 


Simply compile with v.

It will give the error:

warning: implicit tcc could not be used for this build (tcc: error: library 'wgpu_native' not found), regenerating it with C:\mingw64\bin\gcc.exe
C compiler output from the default V compiler:
src.c: In function 'vwebgpu__wgpu_instance_request_adapter':
src.c:18661:62: error: incompatible type for argument 3 of 'wgpuInstanceRequestAdapter'
18661 |         return wgpuInstanceRequestAdapter(instance, options, callback_info);
      |                                                              ^~~~~~~~~~~~~
      |                                                              |
      |                                                              vwebgpu__WGPURequestAdapterCallbackInfo
In file included from src.c:1648:
C:/Users/lazalong/Documents/Projects/_VLang/projects_github/v_webgpu_test/vwebgpu/webgpu.h:6417:162: note: expected 'WGPURequestAdapterCallbackInfo' but argument is of type 'vwebgpu__WGPURequestAdapterCallbackInfo'
 6417 | WGPU_EXPORT WGPUFuture wgpuInstanceRequestAdapter(WGPUInstance instance, WGPU_NULLABLE WGPURequestAdapterOptions const * options, WGPURequestAdapterCallbackInfo callbackInfo) WGPU_FUNCTION_ATTRIBUTE;
      |                                                                                                                                   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~
V compilation failed (c_compilation_error), but no usable V 0.5.2 fallback was found; running `make v1` now...
