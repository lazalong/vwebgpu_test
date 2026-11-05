module main

import vwebgpu
import gg
import sokol.sapp

struct App { // was AppState
mut:
	running bool
	gg      &gg.Context = unsafe { nil }

	instance        vwebgpu.WGPUInstance
	adapter         vwebgpu.WGPUAdapter
	device          vwebgpu.WGPUDevice
	queue           vwebgpu.WGPUQueue
	surface         vwebgpu.WGPUSurface
	// surface_format  vwebgpu.WGPUTextureFormat
	// shader_module   vwebgpu.WGPUShaderModule
	// pipeline_layout vwebgpu.WGPUPipelineLayout
	// bind_layout     vwebgpu.WGPUBindGroupLayout
	// bind_group      vwebgpu.WGPUBindGroup
	// pipeline        vwebgpu.WGPURenderPipeline
	// vertex_buffer   vwebgpu.WGPUBuffer
	// uniform_buffer  vwebgpu.WGPUBuffer
	vertex_count    u32
	surface_width   int
	surface_height  int
	angle           f32
	last_tick       i64
	ready           bool
}

fn main() {
	println('vWebGPU test')

	mut app := &App{}

	if !app.initialise() {
		println("Failed initialisation")
		return 
	}

	app.running = true
	app.run()
}

fn C.GetWindowLongPtrW(hWnd voidptr, nIndex int) voidptr

fn (mut app App) initialise() bool {

	app.gg = gg.new_context(
		width:         800 // TODO 
		height:        int(800 / 2 ) // app.camera.aspect_ratio) // TODO configurable
		create_window: true
		window_title:  'vWebGPU'
		init_fn:       graphics_init  // get hwnd will be valid in this
		frame_fn:      graphics_frame // get hwnd will be valid in this
		event_fn:      graphics_event
		//click_fn:      graphics_click
		//move_fn:       graphics_move
		//keydown_fn:    graphics_keydown
		//scroll_fn:     graphics_scroll
		user_data:     app
	)

	return true
}

fn (mut app App) run() {
	spawn app.main_loop()
	app.gg.run()
	app.shutdown()
}

fn (mut app App) main_loop() {
	for {
	}
}

fn (mut app App) shutdown() {
	println("Shutdown...")
//	vwebgpu.wgpu_surface_unconfigure(voidptr(state.npixels))   //  (state.surface)
// 	vwebgpu.wgpu_queue_release(state.queue)
// 	vwebgpu.wgpu_surface_release(state.surface)
//	vwebgpu.wgpu_surface_release(voidptr(state.npixels))   //  (state.surface)
// 	vwebgpu.wgpu_device_release(state.device)

	app.gg.quit()
}

fn graphics_event(event &gg.Event, mut app App) {
	unsafe { _ := event }
	_ := app
}

struct UserData {
mut:
    adapter vwebgpu.WGPUAdapter
    request_ended bool
}

fn graphics_init(mut app App) {

	// Create a descriptor
	mut desc := vwebgpu.WGPUInstanceDescriptor {}

	// Create the instance using this descriptor
	app.instance = vwebgpu.wgpu_create_instance(&desc)
	
	// Note if we crash before here this means the wgpu_native.dll is not in the exe folder!
	
	if app.instance == unsafe { nil } {
		eprintln('webgpu: failed to create instance')
		sapp.request_quit()
		return
	}
	eprintln("Webgpu instance: ${app.instance}")

	$if macos {
		// macos 
		// layer := C.webgpu_macos_main_window_metal_layer()
		// layer_desc := webgpu.WGPUSurfaceDescriptorFromMetalLayer{
		//		chain: webgpu.WGPUChainedStruct{
		//			next: unsafe { nil }
		//			s_type: .wgpustype_surfacedescriptorfrommetallayer
		//		}
		//		layer: layer
		//	}
	} $else $if windows {

		hwnd := sapp.win32_get_hwnd()
		if hwnd == unsafe { nil } {
			eprintln('Windows: Failed to get the hwnd')
			return
		}
		println("Windows HWND: ${hwnd}")

		hinstance := C.GetWindowLongPtrW(hwnd, -6) // -6 is the constant for GWLP_HINSTANCE
		if hinstance == unsafe { nil } {
			eprintln('Windows: Failed to get the the the hinstance')
			return
		}

		layer_desc := vwebgpu.WGPUSurfaceSourceWindowsHWND {
			chain: vwebgpu.WGPUChainedStruct{
					next: unsafe { nil }
					s_type: .wgpustype_surfacesourcewindowshwnd
				}
			hinstance: hinstance
			hwnd: hwnd
		}

		surface_desc := vwebgpu.WGPUSurfaceDescriptor{
			next_in_chain: &layer_desc.chain
			label: unsafe { nil }
		}

		app.surface = vwebgpu.wgpu_instance_create_surface(app.instance, &surface_desc)
		if app.surface == unsafe { nil } {
			eprintln('webgpu: failed to create a surface from Windows')
			sapp.request_quit()
			return
		}
		println("Surface: ${app.surface}")

	} $else {
		eprintln("ABORT: other os not yet implemented")
		return
	}

	options := vwebgpu.WGPURequestAdapterOptions{
		next_in_chain: unsafe { nil }
		power_preference: .wgpu_power_preference_high_performance
		backend_type: .wgpu_backend_type_undefined
		force_fallback_adapter: 0
		compatible_surface: app.surface
	}

	mut user_data := UserData{
		adapter: unsafe { nil }
		request_ended: false
	}

    // 2. Define callback info
	callback_info := vwebgpu.WGPURequestAdapterCallbackInfo {
		next_in_chain: unsafe { nil }
        mode: .wgpu_callback_mode_wait_any_only // Or wgpu_callback_mode_allow_spontaneous
        callback: on_adapter_request_ended
        userdata1: &user_data
        userdata2: unsafe { nil }
    };

	// 3. Request adapter and get WGPUFuture
	future1 := vwebgpu.wgpu_instance_request_adapter(
		app.instance, 
		&options, // NULL for default options
		vwebgpu.WGPURequestAdapterCallbackInfo(callback_info)) // even without the cast compile fails

	//wait_info := vwebgpu.WGPUFutureWaitInfo {
	_ := vwebgpu.WGPUFutureWaitInfo {
                future: future1
                completed: WGPUBool(0)
	}

    // // 4. Wait for the future to complete (using wgpuInstanceWaitAny)
	// wait_status := vwebgpu.wgpu_instance_wait_any(
    //     app.instance,
    //     1,
    //     &wait_info,
    //     max_u64 // UINT64_MAX // Timeout in nanoseconds (UINT64_MAX = infinite)
    // );

    // assert(wait_status == .wgpu_wait_status_success && user_data.request_ended);
    // assert(user_data.adapter != unsafe { nil });


	eprintln('Graphics init done')
}

fn graphics_frame(mut app App) {
	app.gg.begin()
	//app.draw()
	app.gg.end()
}

fn on_adapter_request_ended(
    status vwebgpu.WGPURequestAdapterStatus,
    adapter vwebgpu.WGPUAdapter,
    message vwebgpu.WGPUStringView,
    userdata1 voidptr,
    userdata2 voidptr
) {
    _ := userdata2
    _ := message

    mut user_data := &UserData(userdata1)
    if status == .wgpu_request_adapter_status_success {
        user_data.adapter = adapter
    } else {
        eprintln("Could not get WebGPU adapter") //  ${message.data}")
    }
    user_data.request_ended = true
}
