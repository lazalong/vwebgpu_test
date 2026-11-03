module vwebgpu

/*
 * vWebGPU: Wrapper for webgpu.h & wgpu.h - version 29.0.1.1 June 2026 
 * https://github.com/gfx-rs/wgpu-native/releases/tag/v29.0.1.1
 * Uses shared lib wgpu_native.dll from same release
 *
 * Copyright (c) 2026 Steven 'lazalong' Gay
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

$if debug {
	#define WEBGPU_DEBUG
}

#define RUST_BACKTRACE  1

#define WGPU_SHARED_LIBRARY
// .. #define WGPU_IMPLEMENTATION
#flag -L @VMODROOT/
#flag -l wgpu_native
#flag -I @VMODROOT/
#include "webgpu.h"
#include "wgpu.h"

// CONSTANTS
pub const vwebgpu_v_version = '0.0.1'
pub const vwebgpu_c_version = '29.0.1.1' // see above

/**
 * \defgroup Constants
 * \brief Constants.
 * 
 * @{
 */
pub const wgpu_array_layer_count_undefined = C.WGPU_ARRAY_LAYER_COUNT_UNDEFINED
pub const wgpu_copy_stride_undefined = C.WGPU_COPY_STRIDE_UNDEFINED
pub const wgpu_depth_slice_undefined = C.WGPU_DEPTH_SLICE_UNDEFINED
pub const wgpu_limit_u32_undefined = C.WGPU_LIMIT_U32_UNDEFINED
pub const wgpu_limit_u64_undefined = C.WGPU_LIMIT_U64_UNDEFINED
pub const wgpu_mpi_level_count_undefined = C.WGPU_MIP_LEVEL_COUNT_UNDEFINED
pub const wgpu_query_set_index_undefined = C.WGPU_QUERY_SET_INDEX_UNDEFINED
pub const wgpu_whole_map_size = C.WGPU_WHOLE_MAP_SIZE - 1
pub const wgpu_whole_size = C.WGPU_WHOLE_SIZE

struct WGPUStringView {
    data &char
    length uint
}

/**
 * \defgroup Typedefs
 * \brief Utility typedefs.
 */
pub type WGPUFlags = u32
pub type WGPUBool = u32

// defgroup Objects
// brief Opaque, non-dispatchable handles to WebGPU objects.
pub type WGPUAdapter = voidptr
pub type WGPUCommandBuffer = voidptr
pub type WGPUCommandEncoder = voidptr
pub type WGPUDevice = voidptr
pub type WGPUInstance = voidptr
pub type WGPUQueue = voidptr
pub type WGPUSurface = voidptr


enum WGPUBackendType {
	wgpu_backend_type_undefined = 0
	wgpu_backend_type_null = 1
	wgpu_backend_type_web_gpu = 2
 	wgpu_backend_type_d3_d11 = 3
	wgpu_backend_type_d3_d12 = 4
	wgpu_backend_type_metal = 5
	wgpu_backend_type_vulkan = 6
	wgpu_backend_type_open_gl = 7
	wgpu_backend_type_open_gles = 8
	wgpu_backend_type_force32 = 2147483646 //- 2147483647
}


//* *The callback mode controls how a callback for an asynchronous operation may be fired. See @ref Asynchronous-Operations for how these are used.
// 
enum WGPUCallbackMode {
	
//*     *`0x00000001` 
//     *Callbacks created with `WGPUCallbackMode_WaitAnyOnly`:
//     *- fire when the asynchronous operation's future is passed to a call to `::wgpuInstanceWaitAny`
//     *  AND the operation has already completed or it completes inside the call to `::wgpuInstanceWaitAny`.
//     
	wgpu_callback_mode_wait_any_only = 1
//*     *`0x00000002` 
//     *Callbacks created with `WGPUCallbackMode_AllowProcessEvents`:
//     *- fire for the same reasons as callbacks created with `WGPUCallbackMode_WaitAnyOnly`
//     *- fire inside a call to `::wgpuInstanceProcessEvents` if the asynchronous operation is complete.
//     
	wgpu_callback_mode_allow_process_events = 2
//*     *`0x00000003` 
//     *Callbacks created with `WGPUCallbackMode_AllowSpontaneous`:
//     *- fire for the same reasons as callbacks created with `WGPUCallbackMode_AllowProcessEvents`
//     *- *may* fire spontaneously on an arbitrary or application thread, when the WebGPU implementations discovers that the asynchronous operation is complete.
//     *
//     *  Implementations _should_ fire spontaneous callbacks as soon as possible.
//     *
//     *@note Because spontaneous callbacks may fire at an arbitrary time on an arbitrary thread, applications should take extra care when acquiring locks or mutating state inside the callback. It undefined behavior to re-entrantly call into the webgpu.h API if the callback fires while inside the callstack of another webgpu.h function that is not `wgpuInstanceWaitAny` or `wgpuInstanceProcessEvents`.
//     
	wgpu_callback_mode_allow_spontaneous = 3
	wgpu_callback_mode_force32 = 2147483646 //- 2147483647
}

enum WGPUInstanceFeatureName {
    /**
     * Enable use of ::wgpuInstanceWaitAny with `timeoutNS > 0`.
     */
    wgpuinstancefeaturename_timedwaitany = 0x00000001
    /**
     * Enable passing SPIR-V shaders to @ref wgpuDeviceCreateShaderModule,
     * via @ref WGPUShaderSourceSPIRV.
     */
    wgpuinstancefeaturename_shadersourcespirv = 0x00000002
    /**
     * Normally, a @ref WGPUAdapter can only create a single device. If this is
     * available and enabled, then adapters won't immediately expire when they
     * create a device, so can be reused to make multiple devices. They may
     * still expire for other reasons.
     */
    wgpuinstancefeaturename_multipledeviceseeradapter = 0x00000003
    wgpuinstancefeaturename_force32 = 0x7FFFFFFF
}



enum WGPUPowerPreference {
	wgpu_power_preference_undefined = 0
	wgpu_power_preference_low_power = 1
	wgpu_power_preference_high_performance = 2
	wgpu_power_preference_force32 = 2147483646 //- 2147483647
}


pub enum WGPURequestAdapterStatus {
	wgpu_request_adapter_status_success = 1  
	wgpu_request_adapter_status_callback_cancelled = 2
	wgpu_request_adapter_status_unavailable = 3
	wgpu_request_adapter_status_error = 4
	wgpu_request_adapter_status_force32 = 2147483646 //- 2147483647
}



pub enum WGPUSType {
    wgpustype_shadersourcespirv = 0x00000001
    wgpustype_shadersourcewgsl = 0x00000002
    wgpustype_renderpassmaxdrawcount = 0x00000003
    wgpustype_surfacesourcemetallayer = 0x00000004
    wgpustype_surfacesourcewindowshwnd = 0x00000005
    wgpustype_surfacesourcexlibwindow = 0x00000006
    wgpustype_surfacesourcewaylandsurface = 0x00000007
    wgpustype_surfacesourceandroidnativewindow = 0x00000008
    wgpustype_surfacesourcexcbwindow = 0x00000009
    wgpustype_surfacecolormanagement = 0x0000000A
    wgpustype_requestadapterwebxroptions = 0x0000000B
    wgpustype_texturecomponentswizzledescriptor = 0x0000000C
    wgpustype_externaltexturebindinglayout = 0x0000000D
    wgpustype_externaltexturebindingentry = 0x0000000E
    wgpustype_compatibilitymodelimits = 0x0000000F
    wgpustype_texturebindingviewdimension = 0x00000010
	//wgpustype_force32 = 2147483646  // 2147483647 0x7FFFFFFF
	wgpustype_force32 = 0x7FFFFFFF  // 2147483647 0x7FFFFFFF
}



/**
 * Status code returned (synchronously) from many operations. Generally
 * indicates an invalid input like an unknown enum value or @ref OutStructChainError.
 * Read the function's documentation for specific error conditions.
 */
enum WGPUStatus {
	wgpustatus_success = 1
	wgpustatus_error = 2
	wgpustatus_force32 0x7fffffff // 2147483646  // 2147483647 0x7FFFFFFF
}



// Status returned from a call to ::wgpuInstanceWaitAny.
enum WGPUWaitStatus {
	/** At least one WGPUFuture completed successfully. */
	wgpu_wait_status_success = 1
	// *No WGPUFutures completed within the timeout.
	wgpu_wait_status_timed_out = 2
	// The call was invalid for some reason
	wgpu_wait_status_error = 3
	wgpu_wait_status_force32 = 2147483646  // 2147483647 0x7FFFFFFF
}

pub type WGPURequestAdapterCallback = fn (WGPURequestAdapterStatus, WGPUAdapter, WGPUStringView, voidptr, voidptr)

pub struct WGPUChainedStruct { 
pub:
	next &WGPUChainedStruct = unsafe { nil }
	s_type WGPUSType
}



pub struct WGPURequestAdapterCallbackInfo {
pub:
	next_in_chain &WGPUChainedStruct = unsafe { nil }
	// Controls when the callback may be called (default 0)
	mode WGPUCallbackMode
	callback WGPURequestAdapterCallback = unsafe { nil }
	userdata1 voidptr
	userdata2 voidptr
}

// Opaque handle to an asynchronous operation. See @ref Asynchronous-Operations for more information.
struct WGPUFuture {
	// Opaque id of the @ref WGPUFuture
	id u64
}

struct WGPUInstanceLimits {
	next_in_chain &WGPUChainedStruct = unsafe { nil }
	timed_wait_any_max_count uint
}


pub struct WGPURequestAdapterOptions { 
pub mut:
	next_in_chain &WGPUChainedStruct     = unsafe { 0 }
	compatible_surface WGPUSurface        
	power_preference WGPUPowerPreference 
	backend_type WGPUBackendType         
	force_fallback_adapter WGPUBool      
}

// Chained in @ref WGPUSurfaceDescriptor to make an @ref WGPUSurface wrapping a Windows [`HWND`](https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/retrieve-hwnd).
pub struct WGPUSurfaceSourceWindowsHWND { 
pub:
	chain WGPUChainedStruct
	// The [`HINSTANCE`](https://learn.microsoft.com/en-us/windows/win32/learnwin32/winmain--the-application-entry-point) for this application.
	// Most commonly `GetModuleHandle(nullptr)`.
	hinstance voidptr
	// The [`HWND`](https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/retrieve-hwnd) that will be wrapped by the @ref WGPUSurface.
	hwnd voidptr
}


// Struct holding a future to wait on, and a `completed` boolean flag.
pub struct WGPUFutureWaitInfo { 
pub:
	// The future to wait on.
	future WGPUFuture
	// Whether or not the future completed.
	completed WGPUBool
}



// Default values can be set using @ref WGPU_INSTANCE_DESCRIPTOR_INIT as initializer.
//[typedef]
pub struct WGPUInstanceDescriptor {
pub mut:
	next_in_chain &WGPUChainedStruct = unsafe { nil }
	required_feature_count uint
	required_features &WGPUInstanceFeatureName = unsafe { nil }
	required_limits &WGPUInstanceLimits = unsafe { nil }
}


// The root descriptor for the creation of an @ref WGPUSurface with `::wgpuInstanceCreateSurface`.
// It isn't sufficient by itself and must have one of the `WGPUSurfaceSource* in its chain.
// See @ref Surface-Creation for more details.
pub struct WGPUSurfaceDescriptor {
pub:	
	next_in_chain &WGPUChainedStruct = unsafe { nil }
	// Label used to refer to the object.
	label &i8
}

// Global procs

// Proc pointer type for @ref wgpuCreateInstance
type WGPUProcCreateInstance = fn (&WGPUInstanceDescriptor) WGPUInstance
// Proc pointer type for @ref wgpuGetInstanceFeatures
//type WGPUProcGetInstanceFeatures = fn (&WGPUInstanceFeatures)
// Proc pointer type for @ref wgpuGetInstanceLimits
type WGPUProcGetInstanceLimits = fn(&WGPUInstanceLimits) WGPUStatus
// Proc pointer type for @ref wgpuHasInstanceFeature
type WGPUProcHasInstanceFeature = fn(&WGPUInstanceFeatureName) WGPUBool
// Proc pointer type for @ref wgpuGetProcAddress
//type WGPUProcGetProcAddress = fn (WGPUDevice, &i8) WGPUProc



// //* *Create a WGPUInstance
// // 
fn C.wgpuCreateInstance(descriptor &WGPUInstanceDescriptor) WGPUInstance

pub fn wgpu_create_instance(descriptor &WGPUInstanceDescriptor) WGPUInstance {
	return C.wgpuCreateInstance(descriptor)
}

fn C.webgpu_macos_main_window_metal_layer() voidptr



//*@} 
//* *\defgroup WGPUInstanceMethods WGPUInstance methods
// *\brief Functions whose first argument has type WGPUInstance.
// * *@{
// 
//* *Creates a @ref WGPUSurface, see @ref Surface-Creation for more details.
// 
fn C.wgpuInstanceCreateSurface(instance WGPUInstance, descriptor &WGPUSurfaceDescriptor) WGPUSurface

pub fn wgpu_instance_create_surface(instance WGPUInstance, descriptor &WGPUSurfaceDescriptor) WGPUSurface {
	return C.wgpuInstanceCreateSurface(instance, descriptor)
}



fn C.wgpuInstanceRequestAdapter(instance WGPUInstance, options &WGPURequestAdapterOptions, callback_info WGPURequestAdapterCallbackInfo) WGPUFuture

pub fn wgpu_instance_request_adapter(instance WGPUInstance, options &WGPURequestAdapterOptions, callback_info WGPURequestAdapterCallbackInfo) WGPUFuture {
	return C.wgpuInstanceRequestAdapter(instance, options, callback_info)
}

// //* *Wait for at least one WGPUFuture in `futures` to complete, and call callbacks of the respective completed asynchronous operations.
// // *
// // *See @ref Wait-Any for more information.
// // WGPURequestAdapterCallbackInfo
fn C.wgpuInstanceWaitAny(instance WGPUInstance, future_count uint, futures &WGPUFutureWaitInfo, timeout_ns u64) WGPUWaitStatus

pub fn wgpu_instance_wait_any(instance WGPUInstance, future_count uint, futures &WGPUFutureWaitInfo, timeout_ns u64) WGPUWaitStatus {
	return C.wgpuInstanceWaitAny(instance, future_count, futures, timeout_ns)
}

